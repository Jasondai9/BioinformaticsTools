#!/bin/bash
#Jason Dai

#Infers the gender of a patient sample based on coverage of the X and Y chromosomes

USAGE="gender.sh sample_file\nNOTE: This program assumes each read length is the same."

#CUTOFFS:
#if the ratio of x to the rest of the genome is greater than this, then probably female
minimum_x_to_other_ratio=0.72

#check the file suffix
if [ -z "$1" ]
then
	printf "$USAGE\n"
else

printf "Name\tRatio\n" > sex_ratios.txt
for f in $(tail -n+2 $1 | cut -f3)
do
	bam=${f}_final.bam
	chromdepth=$(basename $bam .bam)_chromdepth.txt
	
	samtools idxstats $bam > $chromdepth

	#get x and y entries
	x=$(grep chrX $chromdepth | grep -v _)
	y=$(grep chrY $chromdepth | grep -v _)

	#get primary chromosomes
	other_reads=$(grep -v _ $chromdepth | grep -v chrM | grep -v \* |grep -v X | grep -v Y | cut -f3)
	other_length=$(grep -v _ $chromdepth | grep -v chrM | grep -v \* | grep -v X | grep -v Y | cut -f2)
	

	#number of mapped reads
	x_mapped_reads=$(printf "$x" | cut -f3)
	y_mapped_reads=$(printf "$y" | cut -f3)

	total_reads=0
	total_length=0
	for read in $other_reads
	do
		total_reads=$(expr $total_reads + $read)
	done

	for length in $other_length
	do
		total_length=$(expr $total_length + $length)
	done

	#total length of chromosome
	x_length=$(printf "$x" | cut -f2)
	y_length=$(printf "$y" | cut -f2)

	#coverage
	x_coverage=$(echo "scale=3; $x_mapped_reads / $x_length" | bc)
	y_coverage=$(echo "scale=3; $y_mapped_reads / $y_length" | bc)

	total_coverage=$(echo "scale=3; $total_reads / $total_length" | bc) 

	x_to_other_ratio=$(echo "scale=3; $x_coverage / $total_coverage" | bc)

	printf "$(basename $bam _final.bam)\t$x_to_other_ratio\n" >> sex_ratios.txt
done


fi
