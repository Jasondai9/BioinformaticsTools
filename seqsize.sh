#!/bin/bash
#real    3m26.922s
#user    2m3.966s
#sys     0m40.825s


if [ -z "$2" ]; then
	printf "USAGE: seqsize.sh mpileup_file \\\n\tmin_coverage\n\n"
	exit 1
fi

mpileup=$1
min_cov=$2
# total bases: 1954824282
above_cutoff=$(awk -v cov=$min_cov '$4>cov{count++}; END{print count}' ${mpileup})
#above_cutoff=$(awk -v cov=$min_cov '$4>=cov{count++}; $4>0{total++}; END{print count"\t"total"\t"count/total}' ${mpileup})

printf "${min_cov}\t${above_cutoff}\n"