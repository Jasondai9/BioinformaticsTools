oneGB=1000000000

echo "INCOMPLETE tumor samples:" > missing_files.txt
echo "TOO SMALL tumor final bams:" > small_bams.txt
echo "small bam size for tumor samples" > small_bams_size.txt

#check for tumor files
for tsample in $(sed 1d ${samplefile}| cut -f2)
do
	tcount=$(ls -l ${bampath}${tsample}{_,.}* | wc -l) 

	if [ "$tcount" != 10 ];then
		#echo "Sample $tsample has enough files"
		#each sample should generate 10 files, including 5 metrics files, 2 txts. 2 bams and 1 bai
	#else
		echo "Sample $tsample is MISSING FILES! See problems.txt"
		echo "$tsample" >> missing_files.txt
		#Report number of files
	fi

	sizebam=$(ls -l ${bampath}${tsample}.bam| cut -f 5 -d ' ')
	sizefinalbam=$(ls -l ${bampath}${tsample}_final.bam | cut -f 5 -d ' ')
	if [ "$sizefinalbam" -gt "$sizebam" ] && [ "$sizebam" -gt "${oneGB}" ];then
		echo "Sample ${tsample}'s final bam is acceptable size"
		# check if final.bam is bigger than 1GB and greater than the .bam
	else
		echo "Sample ${tsample}'s final bam is TOO SMALL! See problems.txt"
		echo "$tsample" >> small_bams.txt
		echo "$tsample" "$sizefinalbam" >> small_bams_size.txt
	fi
done

echo "INCOMPLETE normal samples:" >> missing_files.txt
echo "TOO SMALL normal final bams:" >> small_bams.txt
echo "small bam size for normal samples" >> small_bams_size.txt


#check for normal files
for nsample in $(sed 1d ${samplefile} | cut -f3)
do
	ncount=$(ls -l ${bampath}${nsample}{_,.}* | sort | uniq | wc -l) 
	#unq for normals that are used for multiple samples

	if [ "$ncount" != 10 ];then
		#echo "Sample $nsample has enough files"
	#else
		echo "Sample $nsample is MISSING FILES! See problems.txt"
		echo "$nsample" >> missing_files.txt
	fi

	sizebam=$(ls -l ${bampath}/${nsample}.bam | cut -f 5 -d ' ')
	sizefinalbam=$(ls -l ${bampath}/${nsample}_final.bam | cut -f 5 -d ' ')

	if [ "$sizefinalbam" -gt "$sizebam" ] && [ "$sizebam" -gt "${oneGB}" ];then
		echo "Sample ${nsample}'s final bam is acceptable size"
		# check if final.bam is bigger than 1GB and greater than the .bam
	else
		echo "Sample ${nsample}'s final bam is TOO SMALL! See problems.txt"
		echo "$nsample" >> small_bams.txt
		echo "$nsample" "$sizefinalbam" >> small_bams_size.txt
	fi
done

cp missing_files.txt problems.txt
cat small_bams.txt >> problems.txt 

grep -v "INCOMPLETE" missing_files.txt > temp.txt
grep -v "bams" small_bams.txt >> temp.txt
sort temp.txt | uniq > bad_samples.txt
grep "sample" ${samplefile} > ${badsamples}

while read sample;
do
	grep $sample ${samplefile} 
done < bad_samples.txt | sort | uniq >> ${badsamples}

rm temp.txt
rm bad_samples.txt
rm missing_files.txt
rm small_bams.txt

c1=$(wc -l ${badsamples}|cut -f 1 -d ' ')
c2=$(wc -l problems.txt|cut -f 1 -d ' ')
c3=$(wc -l small_bams_size.txt|cut -f 1 -d ' ')

if [ $c1 -eq 1 ] && [ $c2 -eq 4 ] && [ $c3 -eq 2 ];then
	echo "CONGRATULATIONS!! ALL ALIGNMENT JOBS HAVE PASSED QC!"
	echo "You may now proceed to stage 2(Panel Of Normals) by running the script to submit the jobs ;)"
	rm small_bams_size.txt
	rm problems.txt
	rm ${badsamples}
else
	echo "Some files failed, the resubmit_alignment_samples.txt has been generated in the directory above"
	chmod 775 ${badsamples}
	mv ${badsamples} ../

fi