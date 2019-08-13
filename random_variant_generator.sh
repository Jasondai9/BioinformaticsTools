#!/bin/bash
#Jason Dai

if [ "$1" == "" ] || [ "$2" == "" ]; then
	printf "\nUSAGE: random_variant_generator.sh directory/of/tissue/type/containing/project/directories number_of_variants\n\n"

else
	RANDOM_NUM=$2
	TISSUE_DIR=$1
	
	NUM_VARIANTS=$(cat ${TISSUE_DIR}/*/consensus_vcf/*all_merged* | grep -v "#" | wc -l)
	NUM_SAMPLES=$(ls ${TISSUE_DIR}/*/consensus_vcf/*all_merged* | wc -l)

	printf "Total num variants: $NUM_VARIANTS\n"
	printf "Total num samples: $NUM_SAMPLES\n"

	awk '{print $0 "\t" FILENAME}' ${TISSUE_DIR}/*/consensus_vcf/*all_merged* | grep -v "#" | shuf -n $RANDOM_NUM | sort -k9 > random.txt
	printf "Random variants saved to random.txt\n\n"
fi