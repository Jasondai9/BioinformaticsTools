#!/bin/bash
#Jason Dai

NUMRUNS=5
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    USAGE="\nUSAGE:\tbenchmark_pbs_setup.sh \\
	path/to/pbs_directory \\
	path/to/output_directory \\
	number_of_nodes_available \\
	number_of_runs (expect 10min each. Default is 5)\n\n"
    printf "$USAGE"
	exit 1
fi

PBS=$1/
OUTPUT=$2/
NUMNODES=$3
NUMRUNS=$4

if [ -z "$4" ]; then NUMRUNS=5; fi

for ((i = 1; i <= $NUMNODES; i++))
do
	#reserve 1 hour for each run
	printf "#PBS -q home-alexandrov
#PBS -l nodes=1:ppn=28:skylake
#PBS -l walltime=${NUMRUNS}:00:00
#PBS -m bea
#PBS -M jasondai.dev@gmail.com
#PBS -o benchmark${i}.o
#PBS -e benchmark${i}.e
#PBS -N benchmark${i}
#PBS -V

~/BioinformaticsTools/benchmark.sh $OUTPUT/benchmark${i} $NUMRUNS
" > $PBS/benchmark${i}.pbs
done

printf "
printf \"\" > $PBS/jobIDS.txt
for f in $PBS/*.pbs;
do
	qsub \$f | awk -v num=\$f -F. '{print \$1\"\\\t\"num}'>> $PBS/jobIDS.txt
done
"> $PBS/submit_all.sh
printf "
all_nodes=\$(python2 \"/opt/sdsc/bin/lsjobs\" --property=alexandrov-node)

printf \"\" > $PBS/temp
for f in \$(cat $PBS/jobIDS.txt | cut -f1)
do
	out=\$(printf \\\"\$all_nodes\\\" | grep \$f | cut -d: -f1)
	if [ -z "\$out" ]; then
		printf \"\\\n\" >> $PBS/temp
	else
		printf \"\$out\\\n\" >> $PBS/temp
	fi
done
paste $PBS/jobIDS.txt $PBS/temp > $PBS/nodes.txt
" > $PBS/check_nodes.sh

chmod 775 $PBS/*