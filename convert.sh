#!/bin/bash
set -e

rm -rf files
mkdir -p files

cp $2 files/slide.pdf
convert $3 files/bg.jpg
convert files/slide.pdf files/p.jpg

{
  echo '{'
  echo "\"pdf_url\": \"/files/slide.pdf\""
  echo ", \"background_url\": \"/files/bg.jpg\""
  echo ", \"caption\": \"$1\""

  n=$(ls files/p-*.jpg | wc -l)
  last=$(expr $n - 1)
  echo ", \"page_urls\": ["
  for i in $(seq 0 $last); do
    if [ $i -ne 0 ]; then
      echo ","
    fi
    echo "\"/files/p-$i.jpg\""
  done
  echo ']'

  echo '}'

} | jq . >| files/index.json
