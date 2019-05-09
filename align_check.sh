#!/bin/bash

#align_check.sh name_of_submit_folder
#must be called from bam folder in analyzed sample directory

#gig is min bam file size
gig=1000000000

echo "Incomplete tumor samples:" > missing_files.txt
echo "Too small tumor final bams:" > small_bams.txt
for tsample in $(sed 1d ../../submits/$1/*.txt | cut -f2)
do
	tcount=$(ls -l $tsample* | wc -l) 

	if [ "$tcount" -eq 10 ];then
		echo "$tsample" "has enough files"
	else
		echo "$tsample" "is missing files! See missing_files.txt"
		echo "$tsample" >> missing_files.txt
	fi

	sizebam=$(ls -l ${tsample}.bam | cut -f 5 -d ' ')
	sizefinalbam=$(ls -l ${tsample}_final.bam | cut -f 5 -d ' ')

	if [ "$sizefinalbam" -gt "$sizebam" ] && [ "$sizebam" -gt "$gig" ];then
		echo "$tsample" "final bam is acceptable size"
	else
		echo "$tsample" "final bam is not acceptable size! See small_bams.txt"
		echo "$tsample" >> small_bams.txt
	fi
done

echo "Incomplete normal samples:" >> missing_files.txt
echo "Too small normal final bams:" >> small_bams.txt
for nsample in $(sed 1d ../../submits/$1/*.txt | cut -f3)
do
	ncount=$(ls -l $nsample* | sort | uniq | wc -l) 

	if [ "$ncount" -eq 10 ];then
		echo "$nsample" "has enough files"
	else
		echo "$nsample" "is missing files! See missing_files.txt"
		echo "$nsample" >> missing_files.txt
	fi

	sizebam=$(ls -l ${nsample}.bam | cut -f 5 -d ' ')
	sizefinalbam=$(ls -l ${nsample}_final.bam | cut -f 5 -d ' ')

	if [ "$sizefinalbam" -gt "$sizebam" ] && [ "$sizebam" -gt "$gig" ];then
		echo "$nsample" "final bam is acceptable size"
	else
		echo "$nsample" "final bam is not acceptable size! See small_bams.txt"
		echo "$nsample" >> small_bams.txt
	fi
done

cp missing_files.txt problems.txt
cat small_bams.txt >> problems.txt 

grep -v "Incomplete" missing_files.txt > temp.txt
grep -v "bams" small_bams.txt >> temp.txt
sort temp.txt | uniq > bad_samples.txt
grep "sample" ../../submits/$1/*.txt | cut -f 1-3 > names_bad_samples.txt

while read sample;
do
	grep $sample ../../submits/$1/*.txt | cut -f 1-3 >> names_bad_samples.txt
done < bad_samples.txt

rm temp.txt
rm bad_samples.txt
rm missing_files.txt
rm small_bams.txt
