#!/bin/bash

USAGE="\nReorders the normal/tumor columns order to match other variant callers (normal-tumor) and separates multi-mutation variants\n\tmuse_postprocessing.sh \\ \n\tmuse_vcf_file\n\n"

if [ -z "$1" ];then printf "$USAGE"; exit 1; fi


vcf_file=${1}

swapped_file=$(basename ${vcf_file} .vcf).swapped.vcf
multiallelic_file=$(basename ${vcf_file} .vcf).multiallelic.vcf
biallelic_file=$(basename ${vcf_file} .vcf).biallelic.vcf


##################
## Swap columns ##
##################

#col10 is the first column
if [ "$(grep "CHROM" ${vcf_file} | cut -f10)" == "TUMOR" ] || [ "$(grep "CHROM" ${vcf_file} | cut -f10)" == "TUMOUR" ]
then
	echo Swapping columns...
	awk 'BEGIN{OFS="\t";}; { t = $10; $10 = $11; $11 = t; print; }' ${vcf_file} > ${swapped_file}
else
	echo Correct order. Copying to sample_swapped.vcf...
	#make a copy to match naming
	cp ${vcf_file} ${swapped_file}
fi

# write headers
grep "#" ${swapped_file} > ${multiallelic_file}
grep "#" ${swapped_file} > ${biallelic_file}

###########################
## Alt allele processing ##
###########################

echo Isolating biallelic variants...
#if col5 has commas, it is multiallelic
grep -v "#" ${swapped_file} | awk 'BEGIN{OFS="\t";}; $5 ~ /,/ { print }' >> ${multiallelic_file}
grep -v "#" ${swapped_file} | awk 'BEGIN{OFS="\t";}; ! ($5 ~ /,/) { print }' >> ${biallelic_file}


chmod 770 $swapped_file $multiallelic_file $biallelic_file