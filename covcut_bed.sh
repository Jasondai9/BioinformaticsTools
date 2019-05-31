#!/bin/bash


for file in "$@"; do

	name=$(echo ${file%.*})

	cov=$(cat $file | awk -F'\t' 'BEGIN{SUM=0}{ SUM+=$3-$2 }END{print SUM}')
	echo -e $name "\t" $cov >> coverage.txt
	
	cat $file | cut -f 1-3 > "$name"_cut.bed

done
