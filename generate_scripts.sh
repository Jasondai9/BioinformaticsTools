#!/bin/bash
#Jason Dai

if [ "$1" == "" ] || [ "$2" == "" ] || [ "$3" == "" ] || [ "$4" == "" ] || [ "$5" == "" ] ; then
    USAGE="\nUSAGE: generate_scripts.sh pmid  tissue_type  author_name  diseaseID  path/to/BioinformaticsTools  [optional: cancer]\n\n\n"
    printf "$USAGE"
else

	PMID=$1
	TISSUE=$2
	AUTHOR=$3
	DISEASE=$4
	PATH_TO_TOOLS=$5
	CANCER=$6
	SAMPLE_FILE=${PMID}_${TISSUE}_${CANCER}sample.txt

	#Ask for confirmation
	echo "Please make sure your CVC_script_generator is up-to-date"
	echo "Also, you must be in login4. If the script cannot mkdir, then it already exists. This is fine."
	echo
	echo "PMID is: ${PMID}"
	echo "Tissue type is: ${TISSUE}"
	echo "lowercase author's name is: ${AUTHOR}"
	echo "Disease ID is: ${DISEASE}"
	echo "Path to BioinformaticsTools is: $PATH_TO_TOOLS"
	if [ "$CANCER" == "" ]; then
		echo "Sample is not cancerous"
	else
		echo "Sample is cancerous"
	fi
	read -p "Is this correct? (y/n)" -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		#create directories - will not overwrite
		mkdir /restricted/alexandrov-group/shared/precancer_analysis/analysis_results/${TISSUE}
		mkdir /restricted/alexandrov-group/shared/precancer_analysis/analysis_results/${TISSUE}/submits
		mkdir /restricted/alexandrov-group/shared/precancer_analysis/analysis_results/${TISSUE}/submits/${PMID}_${DISEASE}
		mkdir /restricted/alexandrov-group/shared/precancer_analysis/analysis_results/${TISSUE}/submits/${PMID}_${DISEASE}/check

		#generate scripts to run pipeline and copy the sample file
		${PATH_TO_TOOLS}/CVC_script_generator.sh alignment $PMID $TISSUE $AUTHOR $DISEASE $CANCER
		${PATH_TO_TOOLS}/CVC_script_generator.sh panel_of_normals $PMID $TISSUE $AUTHOR $DISEASE $CANCER
		${PATH_TO_TOOLS}/CVC_script_generator.sh variant_calling $PMID $TISSUE $AUTHOR $DISEASE $CANCER

		#cd to check directory and generate scripts
		cd /restricted/alexandrov-group/shared/precancer_analysis/analysis_results/${TISSUE}/submits/${PMID}_${DISEASE}/check

		#generate check1
		CHECK1_TEMPLATE=$(cat ${PATH_TO_TOOLS}/stage1check_Alignment_template.sh)

		printf "#!/bin/bash
#Authors: Frances Keer, Phoebe He
#stage1check_Alignment.sh 

bampath=../../../${PMID}_analyzed_${TISSUE}_${DISEASE}/bam/
samplefile=../${PMID}_${TISSUE}_${CANCER}sample.txt
badsamples=${PMID}_resubmit_alignment_samples.txt

${CHECK1_TEMPLATE}
" > stage1check_Alignment.sh



		#generate check2
		CHECK2_TEMPLATE=$(cat ${PATH_TO_TOOLS}/stage2check_PanelOfNormals_template.sh)

		printf "#!/bin/bash
#Authors: Frances Keer, Jason Dai, Phoebe He
#stage2check_PanelOfNormals.sh

ponpath=../../../${PMID}_analyzed_${TISSUE}_${DISEASE}/PON/
samplefile=../${PMID}_${TISSUE}_${CANCER}sample.txt
badsamples=${PMID}_resubmit_pon_samples.txt

${CHECK2_TEMPLATE}
" > stage2check_PanelOfNormals.sh



		#generate check3
		CHECK3_TEMPLATE=$(cat ${PATH_TO_TOOLS}/stage3check_VariantCalling_template.sh)

		printf "#!/bin/bash
#Authors: Frances Keer, Phoebe He
#stage3check_VariantCalling.sh

vcfpath=../../../${PMID}_analyzed_${TISSUE}_${DISEASE}/consensus_vcf/

${CHECK3_TEMPLATE}
" > stage3check_VariantCalling.sh



		#allow rwx for everyone
		cd ../..
		chmod -R 775 ${PMID}_${DISEASE}

	fi
fi