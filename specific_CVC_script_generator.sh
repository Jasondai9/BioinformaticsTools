#!/bin/bash

#Jason Dai

USAGE="\nUSAGE:\tCVC_script_generator.sh  [alignment/panel_of_normals/variant_calling/all]  input/path  output/path  samples/textfile/path output_file_prefix\n\n"


if [ "$1" != "" ] && [ "$2" != "" ] && [ "$3" != "" ] && [ "$4" != "" ]
then
    MODE=$1
	INPUT=$2
	OUTPUT=$3
	SAMPLE_FILE=$4
	PREFIX=${5}

	if [ "$MODE" == "variant_calling" ] #use bam folder for raw data for pon and vc and change fastq to bam in sample file
	then
	#variant calling
	printf "#!/bin/bash \n\n
ConVarCaller.py \\
run \\
$MODE \\
${OUTPUT} \\
/restricted/alexandrov-group/shared/Reference_Genomes/hg38/ \\
${OUTPUT}/bam/ \\
${SAMPLE_FILE} \\
/projects/ps-lalexandrov/shared/gnomAD/af-only-gnomad.hg38.vcf.gz \\
${OUTPUT}/PON/PON.vcf.gz \\
hg38.fa\n" > ${OUTPUT}/submits/${PREFIX}variant_calling.sh

	elif [ "$MODE" == "panel_of_normals" ] #use bam folder for raw data for pon and vc and change fastq to bam in sample file
	then
	#pon
	printf "#!/bin/bash \n\n
ConVarCaller.py \\
run \\
$MODE \\
${OUTPUT} \\
/restricted/alexandrov-group/shared/Reference_Genomes/hg38/ \\
${OUTPUT}/bam/ \\
${SAMPLE_FILE} \\
/projects/ps-lalexandrov/shared/gnomAD/af-only-gnomad.hg38.vcf.gz \\
INTERNAL_PON \\
hg38.fa\n" > ${OUTPUT}/submits/${PREFIX}panel_of_normals.sh

	else
	#alignment
	printf "#!/bin/bash \n\n
ConVarCaller.py \\
run \\
$MODE \\
${OUTPUT} \\
/restricted/alexandrov-group/shared/Reference_Genomes/hg38/ \\
${INPUT} \\
${SAMPLE_FILE} \\
/projects/ps-lalexandrov/shared/gnomAD/af-only-gnomad.hg38.vcf.gz \\
INTERNAL_PON \\
hg38.fa\n" > ${OUTPUT}/submits/${PREFIX}alignment.sh

	fi
chmod 775 -R /restricted/alexandrov-group/shared/precancer_analysis/analysis_results/$TISSUE/submits/${PMID}_${DISEASE}/

else
    printf "$USAGE"
fi

