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

	printf "Random variants saved to random.txt\n"

	#find the minibam and index
	ls $(cut -f9 random.txt | sed 's/consensus_vcf\//minibam\/**/g' | rev | cut -d_ -f3- | rev | awk '{print $0"**"}') | uniq > files.txt
	printf "Total num BAMs to download: $(	ls $(cut -f9 random.txt | sed 's/consensus_vcf\//minibam\/**/g' | rev | cut -d_ -f3- | rev | awk '{print $0"**bam"}') | uniq | wc -l)\n"
	printf "Minibam files to download in files.txt\n\n"


	chmod 766 random.txt files.txt
fi