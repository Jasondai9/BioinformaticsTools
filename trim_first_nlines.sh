#!/bin/bash
#removes first n lines of all input files

n=$1
shift

for file in "$@"; do

	name=$(echo ${file%.*})

	sed 1,"$n"d $file > "$name"_noheader.bed

done


