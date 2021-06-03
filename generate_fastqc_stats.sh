#!/bin/bash
FASTQC=$1
OUT=$2

USAGE="USAGE: generate_fastqc_stats.sh fastqc_dir output"

if [ -z "$1" ] || [ -z "$2" ]
then
	printf "$USAGE\n"
	exit 1
fi

printf "Sample\tBasic Statistics\tPer base sequence quality\tPer tile sequence quality\tPer sequence quality scores\tPer base sequence content\tPer sequence GC content\tPer base N content\tSequence Length Distribution\tSequence Duplication Levels\tOverrepresented sequences\tAdapter Content\n" > $OUT/results.tsv


#make a sample file
for f in $FASTQC/*.zip
do
	sample_name=$(basename $f _fastqc.zip)
	#unzip the .zip archive
	unzip -q -d $OUT/ $f

	printf "$sample_name\t" >> $OUT/results.tsv

	#print all the flags in order
	for flag in $(cut -f1 $OUT/${sample_name}_fastqc/summary.txt)
	do
		printf "$flag\t" >> $OUT/results.tsv
	done
	printf "\n" >> $OUT/results.tsv
done

