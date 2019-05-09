#!/bin/bash

# map format
#fastq_1	fastq_2		outfq_1		outfq_2

USAGE="\nUSAGE: fastq_combine.sh mapfile /path/to/inputfq /path/to/outputfq\n\n"

MAPFILE="$1"
INDIR="$2"
OUTDIR="$3"
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
   	printf "$USAGE"
else
	linenum=1
	in1_arr=($(cut -f1 $MAPFILE))
	in2_arr=($(cut -f2 $MAPFILE))
	out1_arr=($(cut -f3 $MAPFILE))
	out2_arr=($(cut -f4 $MAPFILE))

	for index in "${!in1_arr[@]}"
	do
		echo "cat ${INDIR}/${in1_arr[index]} >> ${OUTDIR}/${out1_arr[index]}"
		echo "cat ${INDIR}/${in2_arr[index]} >> ${OUTDIR}/${out2_arr[index]}"
	done
	
fi