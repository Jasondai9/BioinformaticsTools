#!/bin/bash
USAGE="USAGE: bam_convert.sh [path/to/fastq] [path/to/bam/directory]\n*Path to BAM directory should be a folder containing BAM files"

if [ "$1" != "" ] && ["$2" != ""]; then
    PATH_TO_FASTQ=$1
	PATH_TO_BAM=$2
else
    printf $USAGE
fi

FILES=$2/*.bam

for f in $FILES
do
	printf "Converting $f...\n"
	fname=`basename $f .bam`
	samtools bam2fq -1 $PATH_TO_FASTQ/${fname}_1.fastq -2 $PATH_TO_FASTQ/${fname}_2.fastq $f
done
