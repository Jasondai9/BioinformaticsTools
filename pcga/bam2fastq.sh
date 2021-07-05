#!/bin/bash

if [ ! -f "$2" ]; then
    USAGE="\nUSAGE:\tsamtools_fastq.sh \\ \n\t[PATH_TO_FASTQ_DIR] \\ \n\t[PATH_TO_BAM] \\ \n\t[bam or cram. default: bam]
	Path to BAM directory should be a folder containing BAM files 
	Can optionally pass in a txt file containing path to the files \n\n"
    printf "$USAGE"
    exit
fi

PATH_TO_FASTQ_DIR="$1"
PATH_TO_BAM="$2"
TYPE="$3"

if [ ! -f "$3" ]; then
	TYPE=bam
fi

mkdir -p $PATH_TO_FASTQ_DIR

fname=$(basename $PATH_TO_BAM .${TYPE})
samtools sort -n -o ${PATH_TO_FASTQ_DIR}/${fname}_sorted.${TYPE} -@$(nproc) $PATH_TO_BAM
samtools fastq -1 ${PATH_TO_FASTQ_DIR}/${fname}_1.fastq.gz -2 ${PATH_TO_FASTQ_DIR}/${fname}_2.fastq.gz -s ${PATH_TO_FASTQ_DIR}/${fname}_singleton.fastq.gz -0 ${PATH_TO_FASTQ_DIR}/${fname}_ambiguous.fastq.gz ${PATH_TO_FASTQ_DIR}/${fname}_sorted.${TYPE}

rm ${PATH_TO_FASTQ_DIR}/${fname}_sorted.${TYPE}

chmod 770 ${PATH_TO_FASTQ_DIR}/${fname}_1.fastq.gz ${PATH_TO_FASTQ_DIR}/${fname}_2.fastq.gz ${PATH_TO_FASTQ_DIR}/${fname}_singleton.fastq.gz ${PATH_TO_FASTQ_DIR}/${fname}_ambiguous.fastq.gz
