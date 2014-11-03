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
	PageChanged chan struct{}
	Terminated  chan struct{}
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
	page := 0

	r := mux.NewRouter()
	r.PathPrefix("/files/").Methods("GET", "HEAD").
		Handler(http.StripPrefix("/files", http.FileServer(http.Dir(temp))))

	r.PathPrefix("/view/").Methods("GET", "HEAD").
		Handler(http.StripPrefix("/view", http.FileServer(http.Dir("./view"))))

	r.Path("/polling").Methods("GET").
		HandlerFunc(func(res http.ResponseWriter, req *http.Request) {
		hj, ok := res.(http.Hijacker)
		if !ok {
			http.Error(res, "webserver doesn't support hijacking", http.StatusInternalServerError)
			return
		}

		conn, bufrw, err := hj.Hijack()
		if err != nil {
			http.Error(res, err.Error(), http.StatusInternalServerError)
			return
		}
		defer conn.Close()

		bufrw.WriteString("Content-type: text/event-stream\n")
		bufrw.WriteString("Cache-Control: no-cache\n")
		bufrw.WriteString("Connection: keep-alive\n")
		bufrw.WriteString("\n")
		bufrw.Flush()

		p := &Polling{
			Terminated:  make(chan struct{}, 10),
			PageChanged: make(chan struct{}, 10),
		}
		pollings = append(pollings, p)

		ok = true
		writePage := func() {
			fmt.Println("data:" + strconv.Itoa(page))
			bufrw.WriteString("data:" + strconv.Itoa(page) + "\n")
			err := bufrw.Flush()
			if err != nil {
				fmt.Println(err)
				ok = false
			}
		}
		for ok {
			select {
			case <-p.Terminated:
				fmt.Println("terminated")
				ok = false
				return
			case <-p.PageChanged:
				writePage()
			case <-time.After(3 * time.Second):
				writePage()
			}
		}
	})

	r.Path("/move/{page}").Methods("POST").
		HandlerFunc(func(res http.ResponseWriter, req *http.Request) {
		p, err := strconv.Atoi(mux.Vars(req)["page"])
		if err != nil {
			res.WriteHeader(http.StatusBadRequest)
			return
		}
		page = p

		fmt.Println(pollings)
		for _, p := range pollings {
			go func() {
				p.PageChanged <- struct{}{}
			}()
		}

		res.WriteHeader(http.StatusNoContent)
	})

	r.Path("/terminate").Methods("POST").
		HandlerFunc(func(res http.ResponseWriter, req *http.Request) {

		fmt.Println(len(pollings))
		for _, p := range pollings {
			go func() {
				p.Terminated <- struct{}{}
			}()
		}
		pollings = []*Polling{}

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
