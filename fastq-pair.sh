#!/bin/bash
#Jason Dai

for pair in *_1.fastq
do
	samplename=$(basename $pair _1.fastq)

	if [ $(du -sc ${samplename}_1.fastq | head -n1 | cut -f1) -gt $(du -sc ${samplename}_2.fastq | head -n1 | cut -f1) ]
	then
		larger=${samplename}_1.fastq
		smaller=${samplename}_2.fastq
	else
		larger=${samplename}_2.fastq
		smaller=${samplename}_1.fastq
	fi

	#-t is number of buckets for the hash table: should be close to num of reads
	#fastq_pair -t 70000000 $smaller $larger		#70,000,000 for exome 15GB
	fastq_pair -t 650000000 $smaller $larger	#650,000,000 for genome 150GB


done