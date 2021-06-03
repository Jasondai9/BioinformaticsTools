#!/bin/bash

if [ -f "$2" ]; then
    USAGE="USAGE: cram2bam.sh \\ \n\t[OUTPUT_PATH] \\ \n\t[PATH_TO_CRAM] \\ \n\t[PATH_TO_REF. Default: /projects/ps-lalexandrov/shared/Reference_Genomes/hg38/hg38.fa ]\n"
    printf "$USAGE"
    exit
fi



OUTPUT_PATH="$1"
PATH_TO_CRAM="$2"
PATH_TO_REF="$3"

if [ -f "$3" ]; then
	PATH_TO_REF="/projects/ps-lalexandrov/shared/Reference_Genomes/hg38/hg38.fa"
fi


fname=`basename $PATH_TO_CRAM .cram`

samtools view -b -T $PATH_TO_REF -o ${OUTPUT_PATH}/${fname}.bam $PATH_TO_CRAM