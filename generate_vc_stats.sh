#!/bin/bash
#Jason Dai

#finds the number of variants called at each step by each variant caller (original and filtered)

USAGE="USAGE: generate_vc_stats.sh \\ \ntissue \\ \npmid \\ \npath_to_filtered_consensus_vcf/SNV \\ \noutput_dir \\ \noriginal_bed (sample:chr:pos) \\ \nsample_file\n\n"

TISSUE=$1
PMID=$2
IN=$3/
OUT=$4/$TISSUE
ORIGINAL=$5
samples_file=$6

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] || [ -z "$5" ] || [ -z "$6" ]
then 
	printf "$USAGE"
else

	#create directories
	mkdir -p $OUT/{falsenegative,falsepositive,original,missed,original_0,filtered_1,merged_2,mergeFiltered_4,TrueVariant_5}
	mkdir -p $OUT/falsenegative/{filtered_1,mergeFiltered_4}
	mkdir -p $OUT/falsepositive/{original_0,filtered_1,merged_2,mergeFiltered_4,TrueVariant_5}

#------------------Generate a samples file----------------
	grep $PMID $samples_file | cut -d_ -f1 > $OUT/all_samples.txt

#------------------------Original-------------------------
	echo Generating original .bed files
	echo $(date)
	echo

	#get original from a bed file sample:chr:pos
	for variant in $(cat $ORIGINAL)
	do
		SAMPLE=$(echo $variant | tr ":" "\n" | head -n1)
		CHR=$(echo $variant | tr ":" "\n" | head -n2 | tail -n1)
		POS=$(echo $variant | tr ":" "\n" | tail -n1)

		printf "${CHR}:${POS}\n" >> $OUT/original/$SAMPLE.bed
	done

#---------------------Get the beds------------------------
	echo Getting .bed files from $IN
	echo $(date)
	echo

	#original_0 and filtered_1
	for step in {original_0,filtered_1}
	do
		for variantcaller in {mutect,strelka,varscan}
		do
			for sample in $(cat $OUT/all_samples.txt)
			do
				grep "PASS" ${IN}/${step}/${sample}_${PMID}_${variantcaller}.vcf | grep -v "#" | awk '{print $1":"$2"\t"$7}' | sed 's/chr//g' > ${OUT}/${step}/${sample}_${variantcaller}.bed
			done
		done
	done
	
	#merged_2
	for sample in $(cat $OUT/all_samples.txt)
	do
		awk '{print $1":"$2}' ${IN}/merged_2/${sample}_${PMID}_merged.vcf | grep -v "#" | sed 's/chr//g' > ${OUT}/merged_2/${sample}.bed
	done

	#TrueVariant_5
	for sample in $(cat $OUT/all_samples.txt)
	do
		grep "PASS" ${IN}/TrueVariant_5/${sample}_${PMID}_true.vcf | grep -v "#" | awk '{print $1":"$2}' | sed 's/chr//g' > $OUT/TrueVariant_5/$sample.bed
	done

	#----false negative----

	#filtered_1
	for variantcaller in {mutect,strelka,varscan}
	do
		for sample in $(cat $OUT/all_samples.txt)
		do
			awk '{print $1":"$2"\t"$7}' ${IN}/filtered_1/${sample}_${PMID}_${variantcaller}.vcf | grep -v "#" | sed 's/chr//g' > ${OUT}/falsenegative/filtered_1/${sample}_${variantcaller}.bed
		done
	done

	#mergefiltered_4
	for sample in $(cat $OUT/all_samples.txt)
	do
		awk '{print $1":"$2"\t"$7}' ${IN}/mergeFiltered_4/${sample}_${PMID}_filtered.vcf | grep -v "#" | sed 's/chr//g' > ${OUT}/falsenegative/mergeFiltered_4/${sample}.bed
	done

	#----false positive----

	#original_0 and filtered_1
	for step in {original_0,filtered_1}
	do
		for variantcaller in {mutect,strelka,varscan}
		do
			for sample in $(cat $OUT/all_samples.txt)
			do
				awk '{print $1":"$2"\t"$7}' ${IN}/$step/${sample}_${PMID}_${variantcaller}.vcf | grep -v "#" | grep "PASS" | sed 's/chr//g' > ${OUT}/falsepositive/${step}/${sample}_${variantcaller}.bed
			done
		done
	done

	#merged_2
	for sample in $(cat $OUT/all_samples.txt)
	do
		awk '{print $1":"$2"\t"$7}' ${IN}/merged_2/${sample}_${PMID}_merged.vcf | grep -v "#" | sed 's/chr//g' > ${OUT}/falsepositive/merged_2/${sample}.bed
	done

	#mergeFiltered_4
	for sample in $(cat $OUT/all_samples.txt)
	do
		awk '{print $1":"$2"\t"$7}' ${IN}/mergeFiltered_4/${sample}_${PMID}_filtered.vcf | grep "PASS" | grep -v "#" | sed 's/chr//g' > ${OUT}/falsepositive/mergeFiltered_4/${sample}.bed
	done

	#TrueVariant_5
	for sample in $(cat $OUT/all_samples.txt)
	do
		awk '{print $1":"$2"\t"$11}' ${IN}/TrueVariant_5/${sample}_${PMID}_true.vcf| grep -v "#" | sed 's/chr//g' > ${OUT}/falsepositive/TrueVariant_5/${sample}.bed
	done

#---------------------True VCF stats----------------------
	echo Calculating true.vcf stats
	echo $(date)
	echo

	printf "SAMPLE\tTotal_original\tTotal_filtered\tCommon\tMissed\tFalse_positive\n" > $OUT/TrueVCF_stats.txt

	#Count variants in true
	for sample in $(cat $OUT/all_samples.txt)
	do
		#counter
		declare -i MISSED=0
		declare -i COMMON=0
		pname=$OUT/TrueVariant_5/$sample.bed

		#create the missed variant file
		printf "" > $OUT/missed/${sample}.bed
		
		#for each original variant, check if its in filtered
		for line in $(cat $OUT/original/${sample}.bed)
		do
			
			#if the variant is missing from filtered variants
			if [ $(grep "$line" $pname | wc -l) -eq 0 ]
			then
				MISSED=$MISSED+1
				printf "$line\n" >> $OUT/missed/${sample}.bed
			else
				#else the variant is common
				COMMON=$COMMON+1
			fi
		done

		#false positive=total-original
		declare -i EXTRA=$(cat $pname | wc -l)-$COMMON
		declare -i ototal=$MISSED+$COMMON
		declare -i ftotal=$(cat $pname | wc -l)
		printf "$sample\t$ototal\t$ftotal\t$COMMON\t$MISSED\t$EXTRA\n" >> $OUT/TrueVCF_stats.txt
	done

#--------Missing variants in original variant call--------
	echo Finding missing variants found in early steps
	echo $(date)
	echo
	
	#print header
	printf "Sample\tTotal_missed\toriginal_mutect\toriginal_strelka\toriginal_varscan\tfiltered_mutect\tfiltered_strelka\tfiltered_varscan\tFound_in_merged\tFound_in_true\n" > $OUT/percentages.txt

	#1 line for each sample in original
	for sample in $(cat $OUT/all_samples.txt)
	do
		printf "$sample\t$(cat $OUT/missed/${sample}.bed | wc -l)" >> $OUT/percentages.txt
		for step in {original_0,filtered_1}
		do
			#for each variant caller
			for variantcaller in {mutect,strelka,varscan}
			do
				#counter
				declare -i COMMON=0

				#count the variant if it is common
				for line in $(cat $OUT/missed/${sample}.bed)
				do
					#if the variant is common from vc
					if [ ! -z "$(grep "$line" ${OUT}/${step}/${sample}_${variantcaller}.bed)" ]
					then
						COMMON=$COMMON+1
					fi
				done
				printf "\t$COMMON" >> $OUT/percentages.txt
			done
		done

		#Found in merged

		#counter
		declare -i COMMON=0
		#count the variant if it is common
		for line in $(cat $OUT/missed/${sample}.bed)
		do
			#if the variant is common from vc
			if [ ! -z "$(grep "$line" ${OUT}/merged_2/${sample}.bed)" ]
			then
				COMMON=$COMMON+1
			fi
		done
		printf "\t$COMMON" >> $OUT/percentages.txt
		
		
		#Found in true
		#counter
		declare -i COMMON=0
		#count the variant if it is common
		for line in $(cat $OUT/missed/${sample}.bed)
		do
			#if the variant is common from vc
			if [ ! -z "$(grep "$line" ${OUT}/TrueVariant_5/${sample}.bed)" ]
			then
				COMMON=$COMMON+1
			fi
		done
		printf "\t$COMMON" >> $OUT/percentages.txt
		
		printf "\n" >> $OUT/percentages.txt
	done


#--------------------False negative-----------------------
	echo Finding false negatives
	echo $(date)
	echo

	#header
	printf "Sample\tTotal_missed\tMutect_lowAF\tMutect_lowTLOD\tStrelka_lowAF\tStrelka_lowSomaticEVS\tVarscan_lowAF\tVarscan_lowSCC\tmergeFiltered_lowVAF\tmergeFiltered_nLowCover\tmergeFiltered_tLowCover\n" > $OUT/false_negatives.txt

	#one line per sample
	for sample in $(cat $OUT/all_samples.txt)
	do
		printf "$sample\t$(cat $OUT/missed/${sample}.bed|wc -l)" >> $OUT/false_negatives.txt


		#-----filtered_1-----

		#prints all reasons with duplicates to _filterstats
		for variantcaller in {mutect,strelka,varscan}
		do
			#for each variant
			for line in $(cat $OUT/missed/${sample}.bed)
			do
				#if the variant is missing from vc
				grep $line ${OUT}/falsenegative/filtered_1/${sample}_${variantcaller}.bed | cut -f2 | sed 's/,/\n/g' >> $OUT/falsenegative/filtered_1/${sample}_${variantcaller}.filterstats
			done
		done

		#print counts to file
		printf "\t$(grep "lowAF" $OUT/falsenegative/filtered_1/${sample}_mutect.filterstats | wc -l)" >> $OUT/false_negatives.txt
		printf "\t$(grep "lowTLOD" $OUT/falsenegative/filtered_1/${sample}_mutect.filterstats | wc -l)" >> $OUT/false_negatives.txt
		printf "\t$(grep "lowAF" $OUT/falsenegative/filtered_1/${sample}_strelka.filterstats | wc -l)" >> $OUT/false_negatives.txt
		printf "\t$(grep "lowSomaticEVS" $OUT/falsenegative/filtered_1/${sample}_strelka.filterstats | wc -l)" >> $OUT/false_negatives.txt
		printf "\t$(grep "lowAF" $OUT/falsenegative/filtered_1/${sample}_varscan.filterstats | wc -l)" >> $OUT/false_negatives.txt
		printf "\t$(grep "lowSCC" $OUT/falsenegative/filtered_1/${sample}_varscan.filterstats | wc -l)" >> $OUT/false_negatives.txt


		#----mergeFiltered_4----

		#prints all reasons with duplicates to _filterstats

		#for each variant
		for line in $(cat $OUT/missed/${sample}.bed)
		do
			#if the variant is missing from vc
			grep $line ${OUT}/falsenegative/mergeFiltered_4/${sample}.bed | cut -f2 | sed 's/,/\n/g' >> $OUT/falsenegative/mergeFiltered_4/${sample}.filterstats
		done

		printf "\t$(grep "lowVAF" $OUT/falsenegative/mergeFiltered_4/${sample}.filterstats | wc -l)" >> $OUT/false_negatives.txt
		printf "\t$(grep "nLowCover" $OUT/falsenegative/mergeFiltered_4/${sample}.filterstats | wc -l)" >> $OUT/false_negatives.txt
		printf "\t$(grep "tLowCover" $OUT/falsenegative/mergeFiltered_4/${sample}.filterstats | wc -l)" >> $OUT/false_negatives.txt
		printf "\n" >> $OUT/false_negatives.txt
	done


#--------------------False Positives----------------------
	echo Finding false positives
	echo $(date)
	echo


	for step in {original_0,filtered_1,merged_2,mergeFiltered_4,TrueVariant_5}
	do
		echo Finding false positives for $step
		echo $(date)
		echo
		if [ "$step" == "original_0" ] || [ "$step" == "filtered_1" ]
		then
			

			for variantcaller in {mutect,strelka,varscan}
			do
				#for each sample in original
				for sample in $(cat $OUT/all_samples.txt)
				do
					#oname should be the path to the corresponding original vcf in bed format
					oname=$OUT/original/${sample}.bed

					#for each variant
					for line in $(cut -f1 $OUT/falsepositive/$step/${sample}_${variantcaller}.bed)
					do
						#if the variant is missing from filtered variants
						if [ -z "$(grep "$line" $oname)" ]
						then
							#this is a false positive
							echo $line >> $OUT/falsepositive/${step}/${sample}_${step}_${variantcaller}_fpos.bed
						fi
					done
				done
			done

		else

			#for each sample in original
			for sample in $(cat $OUT/all_samples.txt)
			do
				#oname should be the path to the corresponding original vcf in bed format
				oname=$OUT/original/${sample}.bed
				
				#for each variant
				for line in $(cut -f1 $OUT/falsepositive/$step/${sample}.bed)
				do
					#if the variant is missing from filtered variants
					if [ -z "$(grep "$line" $oname)" ]
					then
						#this is a false positive
						echo $line >> $OUT/falsepositive/${step}/${sample}_${step}_fpos.bed
					fi
				done
			done
		fi
	done

	echo Generating false_positives.txt
	echo $(date)
	echo
	
	#Header
	#printf "Sample\tOriginal_mutect\tOriginal_strelka\tOriginal_varscan\tFiltered_mutect\tFiltered_strelka\tFiltered_varscan\tMerged\tMerge_filtered\tTrueVariant\tRef_depth\tAlt_depth\tVAF\n" > $OUT/false_positives.txt
	printf "Sample\tOriginal_mutect\tOriginal_strelka\tOriginal_varscan\tFiltered_mutect\tFiltered_strelka\tFiltered_varscan\tMerged\tMerge_filtered\tTrueVariant\n" > $OUT/false_positives.txt
	#generate a line for each sample
	for sample in $(cat $OUT/all_samples.txt)
	do
		printf "$sample"
		for step in {original_0,filtered_1,merged_2,mergeFiltered_4,TrueVariant_5}
		do
			if [ "$step" == "original_0" ] || [ "$step" == "filtered_1" ]
			then
				for variantcaller in {mutect,strelka,varscan}
				do
					printf "\t$(grep -v "#" $OUT/falsepositive/${step}/${sample}_${step}_${variantcaller}_fpos.bed | wc -l)"
				done
			else
				printf "\t$(grep -v "#" $OUT/falsepositive/${step}/${sample}_${step}_fpos.bed | wc -l)"
			fi
		done

		#ref depth, alt depth, vaf
		#printf "\t$(cut -d, -f2 $OUT/falsepositive/TrueVariant_5/${sample}_TrueVariant_5_fpos.bed | cut -d: -f9)"
		#printf "\t$(cut -d, -f2 $OUT/falsepositive/TrueVariant_5/${sample}_TrueVariant_5_fpos.bed | cut -d: -f10)"
		#printf "\t$(cut -d, -f2 $OUT/falsepositive/TrueVariant_5/${sample}_TrueVariant_5_fpos.bed | cut -d: -f11)"
		printf "\n"
	done >> $OUT/false_positives.txt

	echo Done!
	echo $(date)
fi