#!/bin/bash

#num_norms.sh name_of_submit_folder
#must be called from PON folder in analyzed sample directory

num=$(sed 1d ../../submits/$1/*.txt | cut -f3 | sort | uniq | wc -l)
pon=$(ls -l *.vcf.gz | sed 1d | wc -l)

echo "number of normals:" "$num"
echo "number of PONs:" "$pon"

if [ "$num" -eq "$pon" ];then
	echo "enough PONs"
elif [ "$num" -gt "$pon" ];then
	echo "not enough PONs"
fi
