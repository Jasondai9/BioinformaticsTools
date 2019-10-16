#!/bin/bash
#Jason Dai

#finds the number of variants called at each step by each variant caller (original and filtered)

USAGE="USAGE: find_score_offset.sh \\ \nfastq_dir \\ \noutput_dir\nCan be either .fastq or .fastq.gz\n\n"

IN_DIR=$1
IN=$1/*_[12].fastq**
OUT=$2

if [ -z "$1" ] || [ -z "$2" ] 
then 
	printf "$USAGE"
else

	mkdir -p $OUT
	#generate a clean file
	printf "" > $OUT/all_offsets.txt

	for f in $IN
	do
		#if the fastqs are gzipped
		if [[ $f =~ \.gz$ ]];
		then
			#get the first 1000 lines since that's enough and save in .fastq
			#may give the error "gzip: stdout: Broken pipe" but that's fine
			zcat $f | head -n 1000 > $OUT/small.temp.fastq
		else
			head -n 1000 $f > $OUT/small.temp.fastq
		fi

		/home/jad054/Downloads/usearch-11.0.667/usearch -fastx_info $OUT/small.temp.fastq -output $OUT/stats.temp > /dev/null 2>&1

		#get the offset
		printf "$(basename $f)\t$(tail -n2 $OUT/stats.temp | head -n1 | cut -d= -f2)\n" >> $OUT/all_offsets.txt
	done


	#rm $OUT/{stats,small}.temp**

	#if there is only one offset value
	if [ $(cut -f2 $OUT/all_offsets.txt | sort | uniq | wc -l) -eq 1 ]
	then
		printf "\nThese samples have offset $(head -n1 $OUT/all_offsets.txt | cut -f2)\n\n"

		#either 64 or 33. 64 needs to be converted
		if [ $(cut -f2 $OUT/all_offsets.txt | sort | uniq) -eq 64 ]
		then
			mkdir -p $OUT/phred33
			for f in $IN
			do
				#if the fastqs are gzipped
				if [[ $f =~ \.gz$ ]];
				then
					name="$(basename $f .fastq.gz)"
					gunzip -c $f > $IN_DIR/${name}.fastq
				else
					name="$(basename $f .fastq)"
				fi

				echo Converting $name
				/home/jad054/Downloads/fastq_phred_convert/fastq_64_to_33.pl $IN_DIR/${name}.fastq > $OUT/phred33/${name}.fastq
			done

			rm $OUT/all_offsets.txt
		fi
	else
		printf "\n\nThese samples have multiple offsets. Please see all_offsets.txt\n"
	fi
fi


