#!/bin/bash

#align_check.sh name_of_submit_folder
#must be called from bam folder in analyzed sample directory

#gig is min bam file size
gig=1000000000

echo "INCOMPLETE tumor samples:" > missing_files.txt
echo "TOO SMALL tumor final bams:" > small_bams.txt
echo "small bam size for tumor samples" > small_bams_size.txt

for tsample in $(sed 1d ../../submits/$1/*.txt | cut -f2)
do
	tcount=$(ls -l ${tsample}{_,.}* | wc -l) 

	if [ "$tcount" -eq 10 ];then
		echo "$tsample" "has enough files"
	else
		echo "$tsample" "is MISSING FILES! See problems.txt"
		echo "$tsample" >> missing_files.txt
	fi

	sizebam=$(ls -l ${tsample}.bam | cut -f 5 -d ' ')
	sizefinalbam=$(ls -l ${tsample}_final.bam | cut -f 5 -d ' ')

	if [ "$sizefinalbam" -gt "$sizebam" ] && [ "$sizebam" -gt "$gig" ];then
		echo "$tsample" "final bam is acceptable size"
	else
		echo "$tsample" "final bam is NOT ACCEPTABLE SIZE! See problems.txt"
		echo "$tsample" >> small_bams.txt
		echo "$tsample" "$sizefinalbam" >> small_bams_size.txt
	fi
done

echo "INCOMPLETE normal samples:" >> missing_files.txt
echo "TOO SMALL normal final bams:" >> small_bams.txt
echo "small bam size for normal samples" >> small_bams_size.txt

for nsample in $(sed 1d ../../submits/$1/*.txt | cut -f3)
do
	ncount=$(ls -l ${nsample}{_,.}* | sort | uniq | wc -l) 

	if [ "$ncount" -eq 10 ];then
		echo "$nsample" "has enough files"
	else
		echo "$nsample" "is MISSING FILES! See problems.txt"
		echo "$nsample" >> missing_files.txt
	fi

	sizebam=$(ls -l ${nsample}.bam | cut -f 5 -d ' ')
	sizefinalbam=$(ls -l ${nsample}_final.bam | cut -f 5 -d ' ')

	if [ "$sizefinalbam" -gt "$sizebam" ] && [ "$sizebam" -gt "$gig" ];then
		echo "$nsample" "final bam is acceptable size"
	else
		echo "$nsample" "final bam is NOT ACCEPTABLE SIZE! See problems.txt"
		echo "$nsample" >> small_bams.txt
		echo "$nsample" "$sizefinalbam" >> small_bams_size.txt
	fi
done

cp missing_files.txt problems.txt
cat small_bams.txt >> problems.txt 

grep -v "INCOMPLETE" missing_files.txt > temp.txt
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
