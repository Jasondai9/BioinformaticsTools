#!/bin/bash

IN=bam_files
OUT=mapped_bam_files

for f in $IN/*.bam
do
	samtools view -bF 4 $f > $OUT/$(basename $f .bam)_mapped.bam
done
