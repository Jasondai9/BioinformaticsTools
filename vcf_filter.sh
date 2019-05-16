#!/bin/bash

if [ "$1" == "" ] || [ "$2" == "" ]; then
    USAGE="\nRemoves sequences found in filter VCF from the input VCF\nFiles cannot be gzipped\nUSAGE: vcf_filter.sh [input vcf] [filter vcf]\n\n"
    printf "$USAGE"
else
	INPUT_VCF="$1"
	FILTER_VCF="$2"

	FILTERED_BASE=`basename $FILTER_VCF .vcf`
	INPUT_BASE=`basename $INPUT_VCF .vcf`
	CLEANED_FILTER=${FILTERED_BASE}_cleaned.vcf
	FILTERED_INPUT=${INPUT_BASE}_filtered.vcf

	grep -v "#" ${FILTER_VCF} | cut -f1,2 > ${CLEANED_FILTER}


	awk 'NR==FNR{field[$1 $2]++;next};!field[$1 $2]' ${CLEANED_FILTER} ${INPUT_VCF} > ${FILTERED_INPUT}

	rm ${CLEANED_FILTER}
fi

