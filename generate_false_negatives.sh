#!/bin/bash
#Jason Dai

#Gives a summary of sensitivity and false positive rate in stats.txt and false negative reasons
#False negative means true variants from author filtered out by our filters

USAGE="USAGE: generate_false_negatives.sh \\ \npath_to_filtered_consensus_vcf/ \\ \noutput_dir \\ \noriginal_consensus_vcf (sample,pos,.,ref,alt) \\ \nsample_file\n\n"

IN=$1/
OUT=$2/
ORIGINAL=$3
samples_file=$4

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]
then 
	printf "$USAGE"
else

	#create directories
	mkdir -p $OUT/{SNVs,INDELs}/{strelka,mutect,varscan,true,original,filtered,igv,vep}
	mkdir -p $OUT/missed/{true,mutect,strelka,varscan}
	mkdir -p $OUT/falsenegative/{filtered,igv,vep}
	mkdir -p $OUT/{SNVs,INDELs}/called/{mutect,strelka,varscan}

#------------------Generate a samples file----------------
	#tail -n+2 $samples_file | cut -d_ -f1 > $OUT/all_samples.txt
	cp $samples_file $OUT/all_samples.txt

#---------------------Get the beds------------------------
	echo Getting .vcf files from $IN
	echo $(date)
	echo

	for sample in $(cat $OUT/all_samples.txt)
	do
		#SNVs
		for vc in {strelka,mutect,varscan}
		do
			newname=$OUT/SNVs/$vc/$sample.vcf
			printf "" > $newname
			#chr pos ref alt
			grep PASS $IN/SNVs/original_0/$sample*$vc* | grep -v "#" | awk '{print $1","$2","$4","$5}' > $newname

			newname=$OUT/SNVs/filtered/${sample}_${vc}.vcf
			printf "" > $newname
			#chr pos ref alt
			grep -v "#" $IN/SNVs/filtered_1/${sample}_**$vc* | awk '{print $1","$2","$4","$5"\t"$7}' > $newname
		done

		newname=$OUT/SNVs/true/$sample.vcf
		printf "" > $newname
		grep PASS $IN/SNVs/TrueVariant_5/${sample}_**SNP* | grep -v "#" | awk '{print $1","$2","$4","$5"\t"$7}' > $newname

		newname=$OUT/SNVs/original/$sample.vcf
		printf "" > $newname
		awk '{print $1","$2","$4","$5}' $ORIGINAL/SNVs/$sample*vcf > $newname

		newname=$OUT/SNVs/igv/$sample.vcf
		printf "" > $newname
		grep -v "#" $IN/SNVs/igv_4/${sample}_**filtered.vcf | awk '{print $1","$2","$4","$5"\t"$7}' > $newname

		newname=$OUT/SNVs/vep/$sample.vcf
		printf "" > $newname
		grep -v "#" $IN/SNVs/TrueVariant_5/${sample}_**SNPfiltered.vcf | awk '{print $1","$2","$4","$5"\t"$7}' > $newname

		#INDELS
		for vc in {strelka,varscan}
		do
			newname=$OUT/INDELs/$vc/$sample.vcf
			printf "" > $newname
			grep PASS $IN/INDELs/original_0/$sample*$vc* | grep -v "#" | awk '{print $1","$2","$4","$5}' > $newname

			newname=$OUT/INDELs/filtered/${sample}_${vc}.vcf
			printf "" > $newname
			grep -v "#" $IN/INDELs/filtered_1/${sample}_**$vc* | awk '{print $1","$2","$4","$5"\t"$7}' > $newname
		done

		newname=$OUT/INDELs/mutect/$sample.vcf
		printf "" > $newname
		#chr pos ref alt
		grep PASS $IN/INDELs/original_0/$sample*mutect* | grep -v "#" | awk '{print $1","$2","$4","$5}' > $newname

		newname=$OUT/INDELs/true/$sample.vcf
		printf "" > $newname
		grep PASS $IN/INDELs/TrueVariant_5/$sample*INDEL* | grep -v "#" | awk '{print $1","$2","$4","$5}' > $newname
	
		newname=$OUT/INDELs/original/$sample.vcf
		printf "" > $newname
		awk '{print $1","$2","$4","$5}' $ORIGINAL/INDELs/$sample*vcf > $newname

		newname=$OUT/INDELs/igv/$sample.vcf
		printf "" > $newname
		grep -v "#" $IN/INDELs/igv_4/${sample}_**filtered.vcf | awk '{print $1","$2","$4","$5"\t"$7}' > $newname

		newname=$OUT/INDELs/vep/$sample.vcf
		printf "" > $newname
		grep -v "#" $IN/INDELs/TrueVariant_5/${sample}_**INDEL* | awk '{print $1","$2","$4","$5"\t"$7}' > $newname
	done

	echo Done copying files $(date)

	for sample in $(cat $OUT/all_samples.txt)
	do
		printf "" > $OUT/missed/true/${sample}_missed_SNV.vcf
		printf "" > $OUT/missed/true/${sample}_missed_INDEL.vcf
		for variantcaller in {mutect,strelka,varscan}
		do
			printf "" > $OUT/missed/$variantcaller/${sample}_missed_SNV.vcf
			printf "" > $OUT/missed/$variantcaller/${sample}_missed_INDEL.vcf
		done
	done


	echo Starting SNV $(date)
	#SNV
	#Sensitivity
	declare -i true_called=0
	declare -i mutect_called=0
	declare -i strelka_called=0
	declare -i varscan_called=0

	#for each sample
	for sample in $(cat $OUT/all_samples.txt)
	do
		#for each variant
		for variant in $(cat $OUT/SNVs/original/$sample.vcf)
		do
			#if called
			if [ ! -z "$(grep $variant $OUT/SNVs/true/$sample.vcf)" ]
			then
				true_called=$true_called+1
			else
				printf "$variant\n" >> $OUT/missed/true/${sample}_missed_SNV.vcf
			fi

			if [ ! -z "$(grep $variant $OUT/SNVs/mutect/$sample.vcf)" ]
			then
				mutect_called=$mutect_called+1
				printf "$variant\n" >> $OUT/SNVs/called/mutect/${sample}_called.vcf
			else
				printf "$variant\n" >> $OUT/missed/mutect/${sample}_missed_SNV.vcf
			fi

			if [ ! -z "$(grep $variant $OUT/SNVs/strelka/$sample.vcf)" ]
			then
				strelka_called=$strelka_called+1
				printf "$variant\n" >> $OUT/SNVs/called/strelka/${sample}_called.vcf
			else
				printf "$variant\n" >> $OUT/missed/strelka/${sample}_missed_SNV.vcf
			fi

			if [ ! -z "$(grep $variant $OUT/SNVs/varscan/$sample.vcf)" ]
			then
				varscan_called=$varscan_called+1
				printf "$variant\n" >> $OUT/SNVs/called/varscan/${sample}_called.vcf
			else
				printf "$variant\n" >> $OUT/missed/varscan/${sample}_missed_SNV.vcf
			fi
		done
	done

	printf "Configuration\tSNV sensitivity\tSNV false positive\tINDEL sensitivity\t INDEL false positive\n" > $OUT/stats.txt

	total=$(cat $OUT/SNVs/original/*.vcf | wc -l)


	printf "True\t$(echo "scale=1;100*$true_called/$total" | bc)\n" > $OUT/SNV_sens.txt
	printf "Mutect\t$(echo "scale=1;100*$mutect_called/$total" | bc)\n" >> $OUT/SNV_sens.txt
	printf "Strelka\t$(echo "scale=1;100*$strelka_called/$total" | bc)\n" >> $OUT/SNV_sens.txt
	printf "Varscan\t$(echo "scale=1;100*$varscan_called/$total" | bc)\n" >> $OUT/SNV_sens.txt

	#false positive
	declare -i true_fp=0
	declare -i mutect_fp=0
	declare -i strelka_fp=0
	declare -i varscan_fp=0

	true_fp=$(expr $(cat $OUT/SNVs/true/*.vcf | wc -l) - $true_called)
	mutect_fp=$(expr $(cat $OUT/SNVs/mutect/*.vcf | wc -l) - $mutect_called)
	strelka_fp=$(expr $(cat $OUT/SNVs/strelka/*.vcf | wc -l) - $strelka_called)
	varscan_fp=$(expr $(cat $OUT/SNVs/varscan/*.vcf | wc -l) - $varscan_called)

	printf "True\t$true_fp\n" > $OUT/SNV_fpos.txt
	printf "Mutect\t$mutect_fp\n" >> $OUT/SNV_fpos.txt
	printf "Strelka\t$strelka_fp\n" >> $OUT/SNV_fpos.txt
	printf "Varscan\t$varscan_fp\n" >> $OUT/SNV_fpos.txt



	echo Starting INDEL $(date)

	#INDEL
	#Sensitivity
	declare -i true_called_indel=0
	declare -i mutect_called_indel=0
	declare -i strelka_called_indel=0
	declare -i varscan_called_indel=0

	#for each sample
	for sample in $(cat $OUT/all_samples.txt)
	do
		#for each variant
		for variant in $(cat $OUT/INDELs/original/$sample.vcf)
		do
			#if called
			if [ ! -z "$(grep $variant $OUT/INDELs/true/$sample.vcf)" ]
			then
				true_called_indel=$true_called_indel+1
			else
				printf "$variant\n" >> $OUT/missed/true/${sample}_missed_INDEL.vcf
			fi

			if [ ! -z "$(grep $variant $OUT/INDELs/mutect/$sample.vcf)" ]
			then
				mutect_called_indel=$mutect_called_indel+1
				printf "$variant\n" >> $OUT/INDELs/called/mutect/${sample}_called.vcf
			else
				printf "$variant\n" >> $OUT/missed/mutect/${sample}_missed_INDEL.vcf
			fi

			if [ ! -z "$(grep $variant $OUT/INDELs/strelka/$sample.vcf)" ]
			then
				strelka_called_indel=$strelka_called_indel+1
				printf "$variant\n" >> $OUT/INDELs/called/strelka/${sample}_called.vcf
			else
				printf "$variant\n" >> $OUT/missed/strelka/${sample}_missed_INDEL.vcf
			fi

			if [ ! -z "$(grep $variant $OUT/INDELs/varscan/$sample.vcf)" ]
			then
				varscan_called_indel=$varscan_called_indel+1
				printf "$variant\n" >> $OUT/INDELs/called/varscan/${sample}_called.vcf
			else
				printf "$variant\n" >> $OUT/missed/varscan/${sample}_missed_INDEL.vcf
			fi
		done
	done

	total_indel=$(cat $OUT/INDELs/original/*.vcf | wc -l)
	printf "True\t$(echo "scale=1;100*$true_called_indel/$total_indel" | bc)\n" > $OUT/INDEL_sens.txt
	printf "Mutect\t$(echo "scale=1;100*$mutect_called_indel/$total_indel" | bc)\n" >> $OUT/INDEL_sens.txt
	printf "Strelka\t$(echo "scale=1;100*$strelka_called_indel/$total_indel" | bc)\n" >> $OUT/INDEL_sens.txt
	printf "Varscan\t$(echo "scale=1;100*$varscan_called_indel/$total_indel" | bc)\n" >> $OUT/INDEL_sens.txt

	#false positive
	declare -i true_fp_indel=0
	declare -i mutect_fp_indel=0
	declare -i strelka_fp_indel=0
	declare -i varscan_fp_indel=0

	true_fp_indel=$(expr $(cat $OUT/INDELs/true/*.vcf | wc -l) - $true_called_indel)
	mutect_fp_indel=$(expr $(cat $OUT/INDELs/mutect/*.vcf | wc -l) - $mutect_called_indel)
	strelka_fp_indel=$(expr $(cat $OUT/INDELs/strelka/*.vcf | wc -l) - $strelka_called_indel)
	varscan_fp_indel=$(expr $(cat $OUT/INDELs/varscan/*.vcf | wc -l) - $varscan_called_indel)

	printf "True\t$true_fp_indel\n" > $OUT/INDEL_fpos.txt
	printf "Mutect\t$mutect_fp_indel\n" >> $OUT/INDEL_fpos.txt
	printf "Strelka\t$strelka_fp_indel\n" >> $OUT/INDEL_fpos.txt
	printf "Varscan\t$varscan_fp_indel\n" >> $OUT/INDEL_fpos.txt

	cp $OUT/SNV_sens.txt $OUT/1.temp
	cut -f2 $OUT/SNV_fpos.txt | paste $OUT/1.temp - > $OUT/2.temp
	cut -f2 $OUT/INDEL_sens.txt | paste $OUT/2.temp - > $OUT/1.temp
	cut -f2 $OUT/INDEL_fpos.txt | paste $OUT/1.temp - > $OUT/2.temp

	cat 2.temp >> $OUT/stats.txt
	mkdir debug
	mv *fpos.txt debug
	mv *sens.txt debug
	mv *.temp debug


#--------------------False negative-----------------------
	echo Finding false negatives
	echo $(date)
	echo

	for category in {SNV,INDEL}
	do
		#header
		printf "Sample\tTotal_missed\tMutect_missed\tStrelka_missed\tVarscan_missed\t\tMutect_called\tStrelka_called\tVarscan_called\t\tMutect_lowAF\tMutect_lowTLOD\tStrelka_lowAF\tStrelka_lowSomaticEVS\tVarscan_lowAF\tVarscan_lowSCC\t\tigv_lowVAF\tigv_nContamination\tigv_nLowCover\tigv_tLowCover\t\tvep_SNPnLowDepth\n" > $OUT/false_negatives_${category}.txt

		#one line per sample
		for sample in $(cat $OUT/all_samples.txt)
		do
			printf "$sample\t$(cat $OUT/missed/true/${sample}_missed_${category}.vcf | wc -l)" >> $OUT/false_negatives_${category}.txt
			#missed
			for variantcaller in {mutect,strelka,varscan}
			do
				printf "\t$(cat $OUT/missed/$variantcaller/${sample}_missed_${category}.vcf | wc -l)" >> $OUT/false_negatives_${category}.txt
			done

			printf "\t" >> $OUT/false_negatives_${category}.txt

			#called
			for variantcaller in {mutect,strelka,varscan}
			do
				printf "\t$(cat $OUT/${category}s/called/$variantcaller/${sample}_called.vcf | wc -l)" >> $OUT/false_negatives_${category}.txt
			done

			printf "\t" >> $OUT/false_negatives_${category}.txt
	
			#prints all reasons with duplicates to _filterstats
			for line in $(cat $OUT/missed/true/${sample}_missed_${category}.vcf)
			do
				#for each vc
				for variantcaller in {mutect,strelka,varscan}
				do
					#-----filtered_1-----
					#if the variant is missing from vc
					grep $line ${OUT}/${category}s/filtered/${sample}_${variantcaller}.vcf | cut -f2 | sed 's/,/\n/g' >> $OUT/falsenegative/filtered/${sample}_${variantcaller}_${category}.filterstats
				done


				#-------igv_4--------
				grep $line ${OUT}/${category}s/igv/${sample}.vcf | cut -f2 | sed 's/,/\n/g' >> $OUT/falsenegative/igv/${sample}_${category}.filterstats

				#--------vep---------
				grep $line ${OUT}/${category}s/vep/${sample}.vcf | cut -f2 | sed 's/,/\n/g' >> $OUT/falsenegative/vep/${sample}_${category}.filterstats
			done

			#print counts to file
			printf "\t$(grep "lowAF" $OUT/falsenegative/filtered/${sample}_mutect_${category}.filterstats | wc -l)" >> $OUT/false_negatives_${category}.txt
			printf "\t$(grep "lowTLOD" $OUT/falsenegative/filtered/${sample}_mutect_${category}.filterstats | wc -l)" >> $OUT/false_negatives_${category}.txt
			printf "\t$(grep "lowAF" $OUT/falsenegative/filtered/${sample}_strelka_${category}.filterstats | wc -l)" >> $OUT/false_negatives_${category}.txt
			printf "\t$(grep "lowSomaticEVS" $OUT/falsenegative/filtered/${sample}_strelka_${category}.filterstats | wc -l)" >> $OUT/false_negatives_${category}.txt
			printf "\t$(grep "lowAF" $OUT/falsenegative/filtered/${sample}_varscan_${category}.filterstats | wc -l)" >> $OUT/false_negatives_${category}.txt
			printf "\t$(grep "lowSCC" $OUT/falsenegative/filtered/${sample}_varscan_${category}.filterstats | wc -l)" >> $OUT/false_negatives_${category}.txt
			printf "\t" >> $OUT/false_negatives_${category}.txt
			printf "\t$(grep "lowVAF" $OUT/falsenegative/igv/${sample}_${category}.filterstats | wc -l)" >> $OUT/false_negatives_${category}.txt
			printf "\t$(grep "nContamination" $OUT/falsenegative/igv/${sample}_${category}.filterstats | wc -l)" >> $OUT/false_negatives_${category}.txt
			printf "\t$(grep "nLowCover" $OUT/falsenegative/igv/${sample}_${category}.filterstats | wc -l)" >> $OUT/false_negatives_${category}.txt
			printf "\t$(grep "tLowCover" $OUT/falsenegative/igv/${sample}_${category}.filterstats | wc -l)" >> $OUT/false_negatives_${category}.txt
			printf "\t" >> $OUT/false_negatives_${category}.txt
			printf "\t$(grep "SNPnLowDepth" $OUT/falsenegative/vep/${sample}_${category}.filterstats | wc -l)" >> $OUT/false_negatives_${category}.txt

			printf "\n" >> $OUT/false_negatives_${category}.txt
		done
	done


	echo Done
	echo $(date)
fi

