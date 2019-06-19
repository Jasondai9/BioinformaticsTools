#!/bin/bash
#Jason Dai

if [ "$1" == "" ] || [ "$2" == "" ] || [ "$3" == "" ] || [ "$3" == "" ] ; then
    USAGE="\nUSAGE: generate_scripts.sh path/to/input_directory  path/to/output_directory  path/to/samples/textfile  path/to/BioinformaticsTools\n\n\n
	Note: output_directory will be created if it doesn't exist"

    printf "$USAGE"
else

	INPUT=$1
	OUTPUT=$2
	SAMPLE_FILE=$3
	PATH_TO_TOOLS=$4


	#Ask for confirmation
	echo "Note: If the script cannot mkdir, then it already exists. Ignore the errors."
	echo
	echo "Path to input directory is: ${INPUT}"
	echo "Path to output directory is: ${OUTPUT}"
	echo "Path to samples file is: ${SAMPLE_FILE}"
	echo "Path to BioinformaticsTools repository is: $PATH_TO_TOOLS"
	read -p "Is this correct? (y/n)" -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		#create directories - will not overwrite
		mkdir ${OUTPUT}
		mkdir ${OUTPUT}/submits
		mkdir ${OUTPUT}/submits/check


		cp $SAMPLE_FILE ${OUTPUT}/submits/

		#generate scripts to run pipeline and copy the sample file
		${PATH_TO_TOOLS}/CVC_script_generator.sh alignment $INPUT $OUTPUT $SAMPLE_FILE
		${PATH_TO_TOOLS}/CVC_script_generator.sh panel_of_normals $INPUT $OUTPUT $SAMPLE_FILE
		${PATH_TO_TOOLS}/CVC_script_generator.sh variant_calling $INPUT $OUTPUT $SAMPLE_FILE


		#cd to check directory and generate scripts
		cd ${OUTPUT}/submits/check/

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