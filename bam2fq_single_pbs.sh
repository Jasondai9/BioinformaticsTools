#!/bin/bash

if [ "$1" == "" ] || ["$2" == ""] || ["$3" == ""] || ["$4" == ""]; then
    USAGE="USAGE: bam2fq_single_pbs.sh [path/to/fastq] [path/to/bam/directory] [email] [job name]\n*Path to BAM directory should be a folder containing BAM files\n"
    printf "$USAGE"
else
	PATH_TO_FASTQ="$1"
	PATH_TO_BAM="$2"
	EMAIL="$3"
	NAME="$4"

	#Ask for confirmation
	echo "Path to FASTQ is: ${PATH_TO_FASTQ}"
	echo "Path to BAM is: ${PATH_TO_BAM}"
	echo "Email: ${EMAIL}"
	echo "Job name is: ${NAME}"
	read -p "Is this correct? (Y/n)" -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		printf "#PBS -q home-alexandrov
#PBS -l nodes=1:ppn=28:skylake
#PBS -l walltime=120:00:00
#PBS -m bea
#PBS -M ${EMAIL}
#PBS -o ${NAME}.o
#PBS -e ${NAME}.e
#PBS -N ${NAME}
#PBS -V


/usr/bin/time -v sh -c '
/home/jad054/BioinformaticsTools/bam_convert.sh ${PATH_TO_FASTQ} ${PATH_TO_BAM}
'" > ${NAME}.pbs


		printf "Done generating ${NAME}.\n"
	fi
fi