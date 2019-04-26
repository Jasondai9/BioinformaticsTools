#!/bin/bash

#usage: bash count_vc.sh, will give num snv and num indels of all files in that directory
#must be in consensus_vcf directory

wc -l *snv_merged.vcf | cut -d - -f 1 | awk '{print $2 "	" $1 -1}' > num_snv.txt
wc -l *indel_merged.vcf | awk '{print $1 -1}' > num_indel.txt

echo -e "sample\tSNV\tindel" > num_var.txt
paste num_snv.txt num_indel.txt >> num_var.txt
sed '$d' num_var.txt

rm num_snv.txt
rm num_indel.txt
