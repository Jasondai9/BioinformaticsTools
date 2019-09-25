#!/bin/bash

if [ "$1" == "" ] || ["$2" == ""] || ["$3" == ""]; then
    USAGE="USAGE: bam_convert.sh [path/to/fastq] [path/to/bam/directory] [email]\n*Path to BAM directory should be a folder containing BAM files\n"
    printf "$USAGE"
else
	PATH_TO_FASTQ="$1"
	PATH_TO_BAM="$2"
	EMAIL="$3"

	FILES=$2/*.bam

	#Ask for confirmation
	echo "Path to FASTQ is: ${PATH_TO_FASTQ}"
	echo "Path to BAM is: ${PATH_TO_BAM}"
	echo "Email: ${EMAIL}"
	read -p "Is this correct? (Y/n)" -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		for f in $FILES
		do
			printf "Generating PBS for $f...\n"
			fname=`basename $f .bam`

			printf "#PBS -q home-alexandrov
#PBS -l nodes=1:ppn=28:skylake
#PBS -l walltime=120:00:00
#PBS -m bea
#PBS -M ${EMAIL}
#PBS -o ${fname}.o
#PBS -e ${fname}.e
#PBS -N ${fname}_bam2fq
#PBS -V

samtools bam2fq -1 ${PATH_TO_FASTQ}/${fname}_1.fastq -2 ${PATH_TO_FASTQ}/${fname}_2.fastq $f" > ${fname}.pbs
			printf "Done generating ${fname}.\n"
		done
	fi
fi