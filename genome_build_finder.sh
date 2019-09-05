#!/bin/bash
#Jason Dai
#Tells you the genome build a bam file is mapped to based on the chromosome lengths

BAM=$1
TEMP=$2/
USAGE="\nUSAGE: genome_build_finder.sh \\ \nfinal/bam/path \\ \noptional: temp_dir_to_write_to\n\n"

CHROM_DIR="/projects/ps-lalexandrov/shared/Reference_Genomes/chrom_sizes"

#if $1 is an empty string
if [ -z "$1" ]
then
	printf "$USAGE"

else
	BAM_SAMPLE_NAME=`basename $BAM .bam`
	BAM_SIZE=bam_chrom_size.sizes

	#print and sort the chromosome sizes - remove chrUn_* and *
	samtools idxstats $BAM | cut -f1,2 | grep -v "_" | grep -v "*" | sort > ${TEMP}${BAM_SIZE}

	for sizes in $CHROM_DIR/*.chrom.sizes
	do
		GENOME=$(basename $sizes .chrom.sizes)
		GENOME_SIZE=${GENOME}_chrom_size.sizes
		
		#print and sort the chromosome sizes
		grep -v "_" $sizes | sort > ${TEMP}${GENOME_SIZE}

		if [ -z "$(diff ${TEMP}${BAM_SIZE} ${TEMP}${GENOME_SIZE})" ]
		then
			printf "\n${BAM_SAMPLE_NAME}'s genome is:\t${GENOME}\n\n"
		fi

		rm ${TEMP}${GENOME_SIZE}
	done

	rm ${TEMP}${BAM_SIZE}
fi