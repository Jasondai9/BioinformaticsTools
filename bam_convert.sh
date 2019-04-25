#!/bin/bash
FILES=./*.bam

for f in $FILES
do
	printf "Converting $f...\n"
	fname=`basename $f .bam`
	samtools bam2fq -1 ${fname}_1.fastq -2 ${fname}_2.fastq $f
done