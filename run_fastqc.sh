#!/bin/bash

FASTQ=$1
OUT=$2

USAGE="run_fastqc.sh path_to_paired_end output_dir"

if [ -z "$1" ] || [ -z "$2" ]
then
	printf "$USAGE\n"
fi

fastqc -o $OUT -t $(nproc) -f fastq $FASTQ/*.fastq.gz