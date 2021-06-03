#!/bin/bash

merged_vcf=$1
vcf1=$2
vcf2=$3
vcf3=$4
vcf4=$5

if [ -z "$5" ]; then exit; fi


tissue=$(basename $merged_vcf _merged_snv.txt)
temp=${tissue}_grep.temp
dnds=${tissue}_dNdScv_input.txt


cut -f1,3-4,6-7 $1 | sed 's/\t/.*/g' > $temp

#rm $temp
printf "" > $dnds
echo 1
grep -Ef $temp $vcf1 >> $dnds
echo 2
grep -Ef $temp $vcf2 >> $dnds
echo 3
grep -Ef $temp $vcf3 >> $dnds
echo 4
grep -Ef $temp $vcf4 >> $dnds