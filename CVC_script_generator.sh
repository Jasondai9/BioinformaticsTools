#!/bin/bash

USAGE="\nUSAGE:\tCVC_script_generator.sh  [alignment/panel_of_normals/variant_calling/all]  pmid  tissue_type  author_name\n \
NOTE:\tThis will output to std:out, so you should redirect output into your script.sh\nAlso, This cancer samples with sample.txt files named differently will need to be changed manually \
ex:\tCVC_script_generator.sh panel_of_normals 27601661 lung jung > /path/to/submits/27601661_lung_pon.sh\n\n"

if [ "$1" != "" ] && [ "$2" != "" ] && [ "$3" != "" ] && [ "$4" != "" ]
then
    MODE=$1
	PMID=$2
	TISSUE=$3
	AUTHOR=$4

	cp /restricted/alexandrov-group/shared/precancer_analysis/tissue_types/${TISSUE}/${PMID}_${AUTHOR}_${TISSUE}/*.txt /restricted/alexandrov-group/shared/precancer_analysis/analysis_results/$TISSUE/submits/

	printf "#!/bin/bash \n\n \
	ConVarCaller.py \\ \n \
	run \\ \n \
	$MODE \\ \n \
	/restricted/alexandrov-group/shared/precancer_analysis/analysis_results/$TISSUE/${PMID}_analyzed_${TISSUE} \\ \n \
	/projects/ps-lalexandrov/shared/Reference_Genomes/hg38/ \\ \n \
	/restricted/alexandrov-group/shared/precancer_analysis/tissue_types/${TISSUE}/${PMID}_${AUTHOR}_${TISSUE}/paired_end/ \\ \n \
	/restricted/alexandrov-group/shared/precancer_analysis/analysis_results/${TISSUE}/submits/${PMID}_${TISSUE}_sample.txt \\ \n \
	/projects/ps-lalexandrov/shared/gnomAD/af-only-gnomad.hg38.vcf.gz \\ \n \
	INTERNAL_PON \\ \n \
	hg38.fa\n"


else
    printf "$USAGE"
fi

