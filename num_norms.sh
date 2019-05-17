#!/bin/bash
#Frances Keer

#num_norms.sh name_of_submit_folder
#must be called from PON folder in analyzed sample directory

num=$(sed 1d ../../submits/$1/*.txt | cut -f3 | sort | uniq | wc -l)
pon=$(ls -l *.vcf.gz | sed 1d | wc -l)

echo "number of normals:" "$num"
echo "number of PONs:" "$pon"

if [ "$num" -eq "$pon" ];then
	echo "enough PONs"
	echo "Generating PON.vcf.gz"
	for v in *vcf.gz;
	do 
		#adds filename to txt file
		printf "--vcfs $v " >> vcf_files.txt
	done
	source activate cvc_py3
	gatk CreateSomaticPanelOfNormals $(cat vcf_files.txt) -O PON.vcf.gz
	
	echo "Indexing PON.vcf.gz"
	gatk IndexFeatureFile --feature-file PON.vcf.gz
	
elif [ "$num" -gt "$pon" ];then
	echo "not enough PONs"
fi
