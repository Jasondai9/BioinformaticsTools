#!/bin/bash
OUT=$1
NUMRUNS=5
NUMRUNS=$2
USAGE="
Note:\tRequires GNU parallel, which will ask you to cite it. This is not an error.
Each run should take roughly 10 min on a compute node.

USAGE:\tbenchmark.sh [full path to writeable output dir] [number_of_runs]"

if [ -z "$1" ]
then
	printf "$USAGE\n"
	exit 1
fi

mkdir -p $OUT/tests/more_files

cd $OUT/tests
output=$OUT/results.txt

printf "Start: $(date)\n\n" > $output

printf "
=========================
========IO Testing=======
=========================
" >> $output

for ((i = 1; i <= $NUMRUNS; i++))
do
	printf "\n\nRun $i\n"
	printf "\nWrite 30GB:\n" >> $output
	(sync; dd if=/dev/zero of=file1 bs=30M count=1024; sync) 2>> write.temp
	tail -1 write.temp >> $output

	printf "\nRead 30GB:\n" >> $output
	(dd if=file1 of=/dev/null bs=30M count=1024) 2>> read.temp
	tail -1 read.temp >> $output

	rm file1 *.temp
done


printf "
=========================
=======CPU Testing=======
=========================
" >> $output

printf "\nClock Speed:\n" >> $output

grep processor /proc/cpuinfo > proc_num.temp
grep cpu\ MHz /proc/cpuinfo > proc_freq.temp
paste proc_num.temp proc_freq.temp | sed 's/\t: \|\tcpu MHz//g' | awk '{print $1":\t"$2" MHz"}'>> $output
rm proc_num.temp proc_freq.temp


cd more_files
#generate nproc*2 files that are 512MB each (28proc = 28GB)
seq $(( $(nproc)*2 )) | parallel -j+0 'dd if=/dev/zero of={} bs=1M count=512 status=none; sync' 2>/dev/null

for ((i = 1; i <= $NUMRUNS; i++))
do
	printf "\n\nRun 1\n"
	printf "\nSingle Threaded gzip:" >> $output
	(time ls | parallel -j1 gzip -1) 2>>$output

	#gunzip is mostly write not cpu
	ls | parallel -j+0 gunzip

	printf "\nMulti Threaded gzip:" >> $output
	(time ls | parallel -j+0 gzip -1) 2>>$output

	ls | parallel -j+0 gunzip
done

rm *.gz

for ((i = 1; i <= $NUMRUNS; i++))
do
	printf "\n\nRun 1\n"
	printf "\nSingle Threaded arithmetic:" >> $output
	(time seq $(( $(nproc)*2 )) | parallel -j1 'i={}; while (( i<999999 )); do (( i ++ ));done') 2>>$output

	printf "\nMulti Threaded arithmetic:" >> $output
	(time seq $(( $(nproc)*2 )) | parallel -j+0 'i={}; while (( i<999999 )); do (( i ++ ));done') 2>>$output
done

cd $OUT
rm -r tests

printf "End: $(date)" >> $output