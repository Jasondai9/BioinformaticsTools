oneMB=1000000

nnum=$(sed 1d ${samplefile}| cut -f3 | sort | uniq | wc -l)
npon=$(ls -l ${ponpath}*.vcf.gz | wc -l)

echo "number of normals:" "$nnum"
echo "number of PONs:" "$npon"

if [ "$nnum" -eq "$npon" ];then
	echo "enough PONs"
	for nsample in $(sed 1d ${samplefile} | cut -f3)
	do
		sizepon=$(ls -l ${ponpath}${nsample}.vcf.gz| cut -f 5 -d ' ')
		if [ "$sizepon" -gt "${oneMB}" ];then
			echo "Sample ${nsample}'s PON.vcf.gz is acceptable size"
		else
		echo "Sample ${nsample}'s PON.vcf.gz is TOO SMALL!"
		grep ${nsample} ${samplefile} >>${badsamples}
		fi
	done

	read -p "Do you want to generate PON.vcf.gz? (y/n)" -n 1 -r
	printf "\\n"
	if [[ $REPLY =~ ^[Yy]$ ]]; then
	echo "Generating PON.vcf.gz"
	for v in ${ponpath}*vcf.gz;
	do 
		#adds filename to txt file
		printf "--vcfs $v " >> vcf_files.txt
	done
	source activate cvc_py3
	gatk CreateSomaticPanelOfNormals $(cat vcf_files.txt) -O ${ponpath}PON.vcf.gz
	rm vcf_files.txt
	echo "Indexing PON.vcf.gz"
	gatk IndexFeatureFile --feature-file ${ponpath}PON.vcf.gz
	echo "You have successfully generated and indexed the Panel of Normals."
	echo "You may run the script to submit jobs for stage 3(variant calling) now :)"
	else
		echo "Everything looks good!"
		echo "If you have PON.vcf.gz generated and indexed, you may run the script to submit jobs for stage 3(variant calling) now :)"
	fi
	
elif [ "$nnum" -gt "$npon" ];then
	echo "not enough PONs"
	echo "The resubmit_pon_samples.txt has been generated in the directory above"
	for nsample in $(sed 1d ${samplefile} | cut -f3)
	do
		ls -R ${nsample}.vcf.gz 2>>list_of_normals.txt
	done

	grep "sample" ${samplefile} > ${badsamples}
	for f in $(cat list_of_normals.txt |cut -f4 -d ' ')
	do
		fname=`basename $f .vcf.gz:`
		grep ${fname} ${samplefile} >>${badsamples}
	done
	cat ${badsamples}|sort|uniq>temp.txt
	cat temp.txt >>${badsamples}
	rm temp.txt
	rm list_of_normals.txt
	rm ${badsamples}
fi
