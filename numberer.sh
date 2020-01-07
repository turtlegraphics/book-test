#!/bin/bash

for chapter in *-*.Rmd
do
    echo $chapter
    python numberer.py fix $chapter > temp
    mv temp $chapter
done
