#!/bin/bash

USAGE="\nReorders the normal/tumor columns order to match other variant callers (normal-tumor)\n\tmutect_cleanup.sh \\ \n\tmutect_vcf_file\n\n"

if [ -z "$1" ];then printf "$USAGE"; exit 1; fi


vcf_file=${1}
normal_name=$(grep normal_sample ${vcf_file} | cut -d= -f2)
tumor_name=$(grep tumor_sample ${vcf_file} | cut -d= -f2)


swapped_file=$(basename ${vcf_file} .vcf).swapped.vcf
multiallelic_file=$(basename ${vcf_file} .vcf).multiallelic.vcf
biallelic_file=$(basename ${vcf_file} .vcf).biallelic.vcf
indel_file=$(basename ${vcf_file} .vcf).indels.vcf
snv_file=$(basename ${vcf_file} .vcf).snvs.vcf
separated_snvs_file=$(basename ${vcf_file} .vcf).snvs.separated.vcf

#change this if additional steps are added
final_vcf=${separated_snvs_file}
final_file=$(basename ${vcf_file} .vcf).snvs.final.vcf


##################
## Swap columns ##
##################

#col10 is the first column
if [ "$(grep "CHROM" ${vcf_file} | cut -f10)" == "${tumor_name}" ]
then
	echo Wrong order. Swapping columns...
	awk 'BEGIN{OFS="\t";}; { t = $10; $10 = $11; $11 = t; print; }' ${vcf_file} > ${swapped_file}
else
	echo Correct order. Copying to sample_swapped.vcf...
	#make a copy to match naming
	cp ${vcf_file} ${swapped_file}
fi



###########################
## Alt allele processing ##
###########################

echo Isolating biallelic variants...
#if col5 has commas, it is multiallelic
grep -v "#" ${swapped_file} | awk 'BEGIN{OFS="\t";}; $5 ~ /,/ { print }' > ${multiallelic_file}
grep -v "#" ${swapped_file} | awk 'BEGIN{OFS="\t";}; ! ($5 ~ /,/) { print }' > ${biallelic_file}



echo Separating SNVs and Indels...
#indels
awk 'BEGIN{OFS="\t";}; length($4) != length($5) { print }' ${biallelic_file} > ${indel_file}
#snvs
awk 'BEGIN{OFS="\t";}; length($4) == length($5) { print }' ${biallelic_file} > ${snv_file}



echo Separating multinecleotide SNVs...
#if len($4) > 1 then this is a group
awk 'BEGIN{OFS="\t";}; 
	{if (length($4) > 1) {
		totalLen = length($4); 
		ref=$4; 
		alt=$5; 
		for (i = 1; i <= totalLen; i++) { 
			new_ref=substr(ref, i, 1); 
			new_alt=substr(alt, i, 1);
			$4 = new_ref
			$5 = new_alt
			print
		}
	}
	else {print}
}' ${snv_file} > ${separated_snvs_file}


#########################
## Generate final file ##
#########################

grep "#" ${swapped_file} > ${final_file}
cat $final_vcf >> ${final_file}

chmod 770 $swapped_file $multiallelic_file $biallelic_file $indel_file $snv_file $separated_snvs_file $final_file