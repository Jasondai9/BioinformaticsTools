#!/bin/bash
FILES=./*.html

mkdir failed_files
printf "Number of warnings and fails per each fastqc:\nFAILS\tWARNINGS\tFILES\n"

for f in $FILES
do
	#fails shows up in the sidebar and the main body, but warning is sidebar only
  	WARNINGS="$(sed 's/WARNING/WARNING\n/g' $f | grep "WARNING" | wc -l)"
	FAILS="$(grep "FAIL" $f | wc -l)"

	# print fails warnings and file
 	printf "${FAILS}\t${WARNINGS}\t$f\n"
	
	if [ $FAILS -gt 0 ]; then
		cp $f failed_files/
	fi
done
printf "Failed files are found in the failed_files directory"