#!/bin/bash

#provide vcf file to be converted to bed file

name=$(echo $1 | cut -d '.' -f 1)

cat $1 | grep "chr" | grep -v "random" | grep -v -w "chrM" | grep -v "chrUn" | awk {'print $1"\t"$2"\t"$2'} > $name.bed

