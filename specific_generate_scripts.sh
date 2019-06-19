#!/bin/bash
#Jason Dai

if [ "$1" == "" ] || [ "$2" == "" ] || [ "$3" == "" ] || [ "$4" == "" ] ; then
    USAGE="\nUSAGE: generate_scripts.sh path/to/input_directory  path/to/output_directory  path/to/samples/textfile  path/to/BioinformaticsTools\nNote: output_directory will be created if it doesn't exist\n\n"

    printf "$USAGE"
else

	INPUT=$1/
	OUTPUT=$2/
	SAMPLE_FILE=$3
	PATH_TO_TOOLS=$4/


	#Ask for confirmation
	echo "Note: Please ignore all mkdir or chmod errors. They are irrelevant."
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
		${PATH_TO_TOOLS}/specific_CVC_script_generator.sh alignment $INPUT $OUTPUT $SAMPLE_FILE
		${PATH_TO_TOOLS}/specific_CVC_script_generator.sh panel_of_normals $INPUT $OUTPUT $SAMPLE_FILE
		${PATH_TO_TOOLS}/specific_CVC_script_generator.sh variant_calling $INPUT $OUTPUT $SAMPLE_FILE


		#cd to check directory and generate scripts
		cd ${OUTPUT}/submits/check/

		#generate check1
		CHECK1_TEMPLATE=$(cat ${PATH_TO_TOOLS}/stage1check_Alignment_template.sh)

		printf "#!/bin/bash
#Authors: Frances Keer, Phoebe He, Jason Dai
#stage1check_Alignment.sh 

bampath=${OUTPUT}/bam/
samplefile=$SAMPLE_FILE
badsamples=${OUTPUT}/submits/resubmit_alignment_samples.txt

${CHECK1_TEMPLATE}

# if there are files to resubmit, generate the script
if [ -f \"${badsamples}\" ]; then
    ${PATH_TO_TOOLS}/specific_CVC_script_generator.sh alignment $INPUT $OUTPUT $SAMPLE_FILE resubmit_
fi
" > stage1check_Alignment.sh



		#generate check2
		CHECK2_TEMPLATE=$(cat ${PATH_TO_TOOLS}/stage2check_PanelOfNormals_template.sh)

		printf "#!/bin/bash
#Authors: Frances Keer, Jason Dai, Phoebe He
#stage2check_PanelOfNormals.sh

ponpath=${OUTPUT}/PON/
samplefile=$SAMPLE_FILE
badsamples=${OUTPUT}/submits/resubmit_panel_of_normals_samples.txt

${CHECK2_TEMPLATE}

# if there are files to resubmit, generate the script
if [ -f \"${badsamples}\" ]; then
    ${PATH_TO_TOOLS}/specific_CVC_script_generator.sh panel_of_normals $INPUT $OUTPUT $SAMPLE_FILE resubmit_
fi
" > stage2check_PanelOfNormals.sh



		#generate check3
		CHECK3_TEMPLATE=$(cat ${PATH_TO_TOOLS}/stage3check_VariantCalling_template.sh)

		printf "#!/bin/bash
#Authors: Frances Keer, Phoebe He
#stage3check_VariantCalling.sh

vcfpath=${OUTPUT}/consensus_vcf/

${CHECK3_TEMPLATE}

# if there are files to resubmit, generate the script
if [ -f \"${badsamples}\" ]; then
    ${PATH_TO_TOOLS}/specific_CVC_script_generator.sh variant_calling $INPUT $OUTPUT $SAMPLE_FILE resubmit_
fi
" > stage3check_VariantCalling.sh



	#allow rwx for everyone
	cd ..
	chmod -R 755 ${OUTPUT}/submits

	fi
fi