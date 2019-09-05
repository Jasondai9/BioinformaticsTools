#!/bin/bash
FILES=./*fq.gz


for f in $FILES
do
	fname=`basename $f .fq.gz`
	echo $fname
	mv $f ${fname}.fastq.gz
done
