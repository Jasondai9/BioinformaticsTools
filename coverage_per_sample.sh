#!/bin/bash

if [ -z "$2" ]; then
	printf "USAGE: coverage.sh \\ \n\tmpileup \\ \n\toutput_dir\n\n"
	exit 1
fi

mpileup=$1
output=$2
mkdir -p $output



sample_name=$(basename $mpileup .mpileup)
printf "required_coverage_cutoff\tnumber_of_bases_above\ttotal_number_of_bases\tpercentage_above_cutoff\n" > ${output}/${sample_name}.txt

#calculate coverage above each coverage cutoff for each sample and print to coverages file
for coverage in {10,20,30,40,50,60,70,80,90,100}; do
	printf "$(~/BioinformaticsTools/seqsize.sh $mpileup $coverage)\n"
done >> ${output}/${sample_name}.txt

