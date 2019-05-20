#!/bin/bash

if [ "$1" == "" ] || [ "$2" == "" ]; then
    USAGE="\nRemoves sequences found in filter VCF from the input VCF\nFiles cannot be gzipped\nUSAGE: vcf_filter.sh [input vcf] [filter vcf]\n\n"
    printf "$USAGE"
else
	INPUT_VCF="$1"
	FILTER_VCF="$2"

	FILTERED_BASE=`basename $FILTER_VCF .vcf.gz`
	INPUT_BASE=`basename $INPUT_VCF .vcf`
	CLEANED_FILTER=${FILTERED_BASE}_cleaned.vcf
	CLEANED_INPUT=${INPUT_BASE}_cleaned.vcf
	FILTERED_INPUT=${INPUT_BASE}_filtered.vcf

	#cleans by removing comments and chr
	zgrep -v "#" ${FILTER_VCF} | sed 's/chr//g' > ${CLEANED_FILTER}
	grep -v "#" ${INPUT_VCF} | sed 's/chr//g' > ${CLEANED_INPUT}

	#removes rows where
	awk 'NR==FNR{field[$1 $2 $4 $5]++;next};!field[$1 $2 $4 $5]' ${CLEANED_FILTER} ${CLEANED_INPUT} > ${FILTERED_INPUT}

	chmod 775 ${CLEANED_FILTER}
	chmod 775 ${CLEANED_INPUT}
	chmod 775 ${FILTERED_INPUT}
fi

