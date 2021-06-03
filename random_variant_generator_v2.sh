#!/bin/bash
#Jason Dai


#random variants from VEPannotated_5
if [ "$1" == "" ] || [ "$2" == "" ]; then
	printf "\nUSAGE: random_variant_generator_v2.sh full/path/to/VEPannotated_5 number_of_variants\n\n"

else
	RANDOM_NUM=$2
	VCF_DIR=$1
	
	NUM_VARIANTS=$(cat ${VCF_DIR}/*vcf | grep -v "#" | wc -l)
	NUM_SAMPLES=$(ls ${VCF_DIR}/*vcf | wc -l)

	printf "Total num variants: $NUM_VARIANTS\n"
	printf "Total num samples: $NUM_SAMPLES\n"

	awk '{print $0 "\t" FILENAME}' ${VCF_DIR}/*vcf | grep -v "#" | shuf -n $RANDOM_NUM | sort -k9 > random.txt

	printf "Random variants saved to random.txt\n"


	#find the minibam and index
	ls $(cut -f12 random.txt | sed 's/consensus_vcf\/VEPannotated_5\//minibam\/**/g' | sed 's/_VEPfiltered.vcf/**/g') | uniq > files.txt
	printf "Total num BAMs to download: $(ls $(cut -f12 random.txt | sed 's/consensus_vcf\/VEPannotated_5\//minibam\/**/g' | sed 's/_VEPfiltered.vcf/**/g') | uniq | wc -l)\n"
	printf "Minibam files to download in files.txt\n\n"


	chmod 766 random.txt files.txt
fi