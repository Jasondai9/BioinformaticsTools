#!/bin/bash

if [ -z "$2" ]; then
	printf "USAGE: coverage.sh \\ \n\tproject_dir \\ \n\toutput_dir\n\n"
	exit 1
fi

project_dir=$1
output=$2
mkdir -p $output

printf "samples are from ${project_dir}\nsample_name\trequired_coverage_cutoff\tnumber_of_bases_above\ttotal_number_of_bases\tpercentage_above_cutoff\n" > ${output}/coverages.txt

# find the mpileup for each sample in the project directory
for sample in ${project_dir}/PCGA*; do
	mpileup=${sample}/mpileup/*.mpileup
	sample_name=$(basename $sample)

	#calculate coverage above each coverage cutoff for each sample and print to coverages file
	for coverage in {10,20,30,40,50,60,70,80,90,100}; do
		printf "${sample_name}\t$(~/BioinformaticsTools/seqsize.sh $mpileup $coverage)\n"
	done >> ${output}/coverages.txt
done