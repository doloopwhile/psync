#!/bin/bash
set -e

rm -rf files
mkdir -p files

cp $1 files/slide.pdf
convert files/slide.pdf files/p.jpg

{
  echo '{'
  echo "\"PdfUrl\": \"/files/slide.pdf\""

  n=$(ls files/p-*.jpg | wc -l)
  last=$(expr $n - 1)
  echo ", \"PageUrls\": ["
  for i in $(seq 0 $last); do
    if [ $i -ne 0 ]; then
      echo ","
    fi
    echo "\"/files/$i.jpg\""
  done
  echo ']'

  echo '}'

} | jq . >| files/index.json
