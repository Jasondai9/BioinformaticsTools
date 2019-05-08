#!/bin/bash
FILES=./*flagstat*

#call from the bam folder containing flagstats

#if they want all files then add "all" after the command
if [ "$1" == "all" ]
then
	printf "Stats for all BAMS\nSAMPLE\tPASS\tFAIL\n"
	for f in $FILES
	do
		fname=`basename $f _flagstat.txt`
		PASSED_READS="$(head -1 $f | cut -f1 -d' ')"
		FAILED_READS="$(head -1 $f | cut -f3 -d' ')"
		printf "$fname\t$PASSED_READS\t$FAILED_READS\n"
	done

#if no parameters then just print the important ones
else
	printf "BAM files that had less than 1000 passes or nonzero fails:\nSAMPLE\tPASS\tFAIL\n"
	for f in $FILES
	do
		fname=`basename $f _flagstat.txt`
		PASSED_READS=$(head -1 $f | cut -f1 -d' ')
		FAILED_READS=$(head -1 $f | cut -f3 -d' ')
				
		#print the stats if less than 1000 passed or greater than 0 fails
		if [ "$PASSED_READS" != "" ] && [ "$FAILED_READS" != "" ];
		then
			if [ "$PASSED_READS" -lt 1000 ] || [ "$FAILED_READS" -gt 0 ]; 
			then
				printf "$fname\t$PASSED_READS\t$FAILED_READS\n"
			fi
		fi
	done
fi
