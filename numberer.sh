#!/bin/bash

if [ "$1" == "fix" ]
then
    echo "Converting @exercise. to numbers"
elif [ "$1" == "unfix" ]
then
    echo "Converting numbered exercises back to @exercise."
else
    echo "Call this with either fix or unfix as an argument"
    exit 1
fi

for chapter in *-*.Rmd
do
    echo $chapter
    python numberer.py $1 $chapter > temp
    mv temp $chapter
done
