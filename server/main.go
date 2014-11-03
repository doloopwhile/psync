package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"strconv"
	"sync"
	"time"

	"github.com/codegangsta/negroni"
	"github.com/gorilla/mux"
)

func usage() {
	fmt.Fprintf(os.Stderr, "server PDFFILE\n")
	os.Exit(2)
}

func fail(err error) {
	fmt.Fprintln(os.Stderr, err)
	os.Exit(2)
}

func copyFile(src, dst string, perm os.FileMode) error {
	data, err := ioutil.ReadFile(src)
	if err != nil {
		return err
	}
	return ioutil.WriteFile(dst, data, perm)
}

type Index struct {
	PdfUrl   string   `json:"pdf_url"`
	PageUrls []string `json:"page_urls"`
}

type Polling struct {
	Page chan int
	Term chan struct{}
}

func main() {
	if len(os.Args) != 2 {
		usage()
	}

	temp, err := ioutil.TempDir(os.TempDir(), "psync")
	if err != nil {
		fail(err)
	}

	cmd := exec.Command("convert", os.Args[1], path.Join(temp, "p.jpg"))
	if err := cmd.Run(); err != nil {
		fail(err)
	}

	pdfName := path.Base(os.Args[1])
	if err := copyFile(os.Args[1], path.Join(temp, pdfName), 0700); err != nil {
		fmt.Fprintf(os.Stderr, "failed to copy %s", os.Args[1])
		fail(err)
	}
	paths, err := filepath.Glob(path.Join(temp, "p-*.jpg"))
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to glob image files")
		fail(err)
	}

	index := &Index{
		PdfUrl: "/files/" + pdfName,
	}
	for i, _ := range paths {
		url := fmt.Sprintf("/files/p-%d.jpg", i+1)
		index.PageUrls = append(index.PageUrls, url)
	}

	fp, err := os.Create(path.Join(temp, "index.json"))
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to create index file")
		fail(err)
	}
	if err := json.NewEncoder(fp).Encode(index); err != nil {
		fmt.Fprintf(os.Stderr, "failed to create index file")
		fail(err)
	}
	fp.Close()

	pollings := []*Polling{}

	r := mux.NewRouter()
	r.PathPrefix("/files/").Methods("GET", "HEAD").
		Handler(http.StripPrefix("/files", http.FileServer(http.Dir(temp))))

	r.Path("/polling").Methods("GET").HandlerFunc(
		func(res http.ResponseWriter, req *http.Request) {
			res.Header().Set("Content-type", "text/event-stream")
			res.Header().Set("Cache-Control", "no-cache")
			res.Header().Set("Connection", "keep-alive")

			p := &Polling{
				Page: make(chan int),
				Term: make(chan struct{}),
			}
			pollings = append(pollings, p)
			for {
				select {
				case <-time.After(time.Second):
					fmt.Println("data:nop")
					res.Write([]byte("data:nop"))
				case n := <-p.Page:
					fmt.Println("data:" + strconv.Itoa(n))
					res.Write([]byte("data:" + strconv.Itoa(n)))
				case <-p.Term:
					break
				}
			}
		})

	r.Path("/move/{page}").Methods("POST").
		HandlerFunc(func(res http.ResponseWriter, req *http.Request) {
		page, err := strconv.Atoi(mux.Vars(req)["page"])
		if err != nil {
			res.WriteHeader(http.StatusBadRequest)
			return
		}

		wg := sync.WaitGroup{}
		for _, p := range pollings {
			wg.Add(1)
			go func() {
				p.Page <- page
				wg.Done()
			}()
		}

		wg.Wait()
		res.WriteHeader(http.StatusNoContent)
	})

	n := negroni.New()
	n.Use(negroni.NewRecovery())
	n.Use(negroni.NewLogger())
	n.UseHandler(r)

	port := os.Getenv("PORT")
	if port == "" {
		port = "3000"
	}

	host := os.Getenv("HOST")

	n.Run(host + ":" + port)
}
