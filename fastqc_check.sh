#!/bin/bash
FILES=./*.html

printf "Number of warnings and fails per each fastqc:\nFAILS\tWARNINGS\tFILES\n"
for f in $FILES
do
	#fails shows up in the sidebar and the main body, but warning is sidebar only
  	WARNINGS="$(sed 's/WARNING/WARNING\n/g' $f | grep "WARNING" | wc -l)"
	FAILS="$( grep "FAIL" $f | wc -l)"

	# print fails warnings and file
 	printf "${FAILS}\t${WARNINGS}\t$f\n"
done
