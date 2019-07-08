#!/bin/bash


#this script uses biobambam2 to convert bam/cram/sam to fastq
if [ "$1" == "" ] || [ "$2" == "" ] || [ "$3" == "" ]; then
    USAGE="\nUSAGE: convert_to_fastq.sh [path/to/fastq] [path/to/input/directory] [bam/cram/sam] [OPTIONAL: text file containing path to individual bams] \n
	Path to input directory should be a folder containing BAM/CRAM/SAM files 
	bam/cram/sam must be lowercase
	Can optionally pass in a txt file containing path to the files \n\n"
    printf "$USAGE"
else
	PATH_TO_FASTQ="$1"
	PATH_TO_INPUT="$2"
	FILE_TYPE="$3"

	FILES=${PATH_TO_INPUT}/*.${FILE_TYPE}
	if [ "$4" != "" ]; then
		printf "Using files from $4"
		#the text file
		FILES=$(cat $4)
	fi
	#No confirmation
	for f in $FILES
	do
		printf "Converting $f...\n"
		fname=`basename $f .${FILE_TYPE}`
		
		#RUNNING BIOBAMBAM2's BAMTOFASTQ
		#gzip lvl 6 is default for gzip
		bamtofastq F=${PATH_TO_FASTQ}/${fname}_1.fastq.gz F2=${PATH_TO_FASTQ}/${fname}_2.fastq.gz inputformat=${FILE_TYPE} gz=1 level=6 < $f
		
		printf "Finished converting ${fname}\n"
		chmod 775 ${PATH_TO_FASTQ}/*.fastq.gz
	done
fi