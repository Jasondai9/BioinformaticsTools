#!/bin/bash

if [ "$1" == "" ] || [ "$2" == "" ] || [ "$3" == "" ] || [ "$4" == "" ] || [ "$5" == "" ]; then
    USAGE="USAGE: cram2fq_single_pbs.sh [PATH_TO_CRAM] [PATH_TO_BAM] [PATH_TO_FASTQ] [email] [job name]\n*Path to CRAM directory should be a folder containing CRAM files and BAM dir is a temp folder\n"
    printf "$USAGE"
else
	PATH_TO_CRAM="$1"
	PATH_TO_BAM="$2"
	PATH_TO_FASTQ="$3"
	EMAIL="$4"
	NAME="$5"

	#Ask for confirmation
	echo "Path to FASTQ is: ${PATH_TO_FASTQ}"
	echo "Path to BAM is: ${PATH_TO_BAM}"
	echo "Path to CRAM is: ${PATH_TO_CRAM}"
	echo "Email: ${EMAIL}"
	echo "Job name is: ${NAME}"
	echo "Walltime is: 170 h"
	read -p "Is this correct? (Y/n)" -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		printf "#PBS -q home-alexandrov
#PBS -l nodes=1:ppn=28:skylake
#PBS -l walltime=170:00:00
#PBS -m bea
#PBS -M ${EMAIL}
#PBS -o ${NAME}.o
#PBS -e ${NAME}.e
#PBS -N ${NAME}
#PBS -V


/usr/bin/time -v sh -c '
echo /home/jad054/BioinformaticsTools/cram2bam.sh ${PATH_TO_BAM} ${PATH_TO_CRAM}
'

/usr/bin/time -v sh -c '
echo /home/jad054/BioinformaticsTools/bam_convert.sh ${PATH_TO_FASTQ} ${PATH_TO_BAM}
'

" > ${NAME}.pbs

		printf "Done generating ${NAME}.\n"
	fi
fi