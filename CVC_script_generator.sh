#!/bin/bash

USAGE="\nUSAGE:\tCVC_script_generator.sh  [alignment/panel_of_normals/variant_calling/all]  pmid  tissue_type  author_name  diseaseID [optional: cancer]\n
ex:\tCVC_script_generator.sh panel_of_normals 27601661 lung jung SH 
ex cancer: CVC_script_generator.sh variant_calling 29486792 esophagus galipeau BE cancer\n\n"


if [ "$1" != "" ] && [ "$2" != "" ] && [ "$3" != "" ] && [ "$4" != "" ] && [ "$5" != "" ] 
then
    MODE=$1
	PMID=$2
	TISSUE=$3
	AUTHOR=$4
	DISEASE=$5
	SAMPLE_FILE=${PMID}_${TISSUE}_$6sample.txt

	#mkdir /restricted/alexandrov-group/shared/precancer_analysis/analysis_results/$TISSUE/submits/${PMID}_${DISEASE}
	cp /restricted/alexandrov-group/shared/precancer_analysis/tissue_types/${TISSUE}/${PMID}_${AUTHOR}_${TISSUE}/${SAMPLE_FILE} /restricted/alexandrov-group/shared/precancer_analysis/analysis_results/$TISSUE/submits/${PMID}_${DISEASE}

	if [ "MODE" == "variant_calling" ]
	then
	printf "#!/bin/bash \n\n
ConVarCaller.py \\
run \\
$MODE \\
/restricted/alexandrov-group/shared/precancer_analysis/analysis_results/$TISSUE/${PMID}_analyzed_${TISSUE}_${DISEASE} \\
/restricted/alexandrov-group/shared/Reference_Genomes/hg38/ \\
/restricted/alexandrov-group/shared/precancer_analysis/tissue_types/${TISSUE}/${PMID}_${AUTHOR}_${TISSUE}/paired_end/ \\
/restricted/alexandrov-group/shared/precancer_analysis/analysis_results/${TISSUE}/submits/${PMID}_${DISEASE}/${SAMPLE_FILE} \\
/projects/ps-lalexandrov/shared/gnomAD/af-only-gnomad.hg38.vcf.gz \\
/restricted/alexandrov-group/shared/precancer_analysis/analysis_results/$TISSUE/${PMID}_analyzed_${TISSUE}_${DISEASE}/PON/PON.vcf.gz \\
hg38.fa\n" > /restricted/alexandrov-group/shared/precancer_analysis/analysis_results/$TISSUE/submits/${PMID}_${DISEASE}/${PMID}_${TISSUE}_${MODE}.sh

	else
	printf "#!/bin/bash \n\n
ConVarCaller.py \\
run \\
$MODE \\
/restricted/alexandrov-group/shared/precancer_analysis/analysis_results/$TISSUE/${PMID}_analyzed_${TISSUE}_${DISEASE} \\
/restricted/alexandrov-group/shared/Reference_Genomes/hg38/ \\
/restricted/alexandrov-group/shared/precancer_analysis/tissue_types/${TISSUE}/${PMID}_${AUTHOR}_${TISSUE}/paired_end/ \\
/restricted/alexandrov-group/shared/precancer_analysis/analysis_results/${TISSUE}/submits/${PMID}_${DISEASE}/${SAMPLE_FILE} \\
/projects/ps-lalexandrov/shared/gnomAD/af-only-gnomad.hg38.vcf.gz \\
INTERNAL_PON \\
hg38.fa\n" > /restricted/alexandrov-group/shared/precancer_analysis/analysis_results/$TISSUE/submits/${PMID}_${DISEASE}/${PMID}_${TISSUE}_${MODE}.sh
	fi
chmod 775 -R /restricted/alexandrov-group/shared/precancer_analysis/analysis_results/$TISSUE/submits/${PMID}_${DISEASE}/

else
    printf "$USAGE"
fi

