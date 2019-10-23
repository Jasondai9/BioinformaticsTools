#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    USAGE="\nUSAGE:\tsamtools_fastq.sh \\ \n\t[path/to/fastq] \\ \n\t[path/to/bam/directory] \\ \n\t[bam/cram] \\ \n\t[OPTIONAL: text file containing path to individual bams] \n
	Path to BAM directory should be a folder containing BAM files 
	Can optionally pass in a txt file containing path to the files \n\n"
    printf "$USAGE"
else
	PATH_TO_FASTQ="$1"
	PATH_TO_BAM="$2"
	TYPE="$3"

	FILES=$PATH_TO_BAM/*.${TYPE}
	if [ "$4" != "" ]; then
		printf "Using files from $4\n\n"
		FILES=$(cat $4)
		cd $PATH_TO_BAM
	fi

	mkdir -p $PATH_TO_FASTQ


	for f in $FILES
	do
		printf "Converting $f START: $(date)\n"
		fname=`basename $f .${TYPE}`
		
		samtools sort -n -o ${PATH_TO_FASTQ}/${fname}_sorted.${TYPE} -m 6G -@$(nproc) $f
		samtools fastq -1 ${PATH_TO_FASTQ}/${fname}_1.fastq.gz -2 ${PATH_TO_FASTQ}/${fname}_2.fastq.gz -s ${PATH_TO_FASTQ}/${fname}_singleton.fastq.gz -0 ${PATH_TO_FASTQ}/${fname}_ambiguous.fastq.gz ${PATH_TO_FASTQ}/${fname}_sorted.${TYPE}

		rm ${PATH_TO_FASTQ}/${fname}_sorted.${TYPE}

		printf "Finished converting ${fname}. END: $(date)\n"

	done
	chmod 775 ${PATH_TO_FASTQ}/*.fastq.gz

fi