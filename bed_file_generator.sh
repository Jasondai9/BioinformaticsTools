#!/bin/bash
#Jason Dai

#generates bed files of a 50bp region around each variant of each VCF file

USAGE="\nUSAGE: bed_file_generator.sh [folder for vcfs] [folder for beds]\n\n"

if [ -z "$1" ] || [ -z "$2" ]; then
   	printf "$USAGE"
else
	VCFs=$1
	BEDs=$2

	FILES=${VCFs}/*.vcf
	mkdir -p ${BEDs}

	for f in $FILES
	do
		fname=`basename $f .vcf`
		cat $f | grep -v "#" | awk -F'["\t"]' '{print $1,"\t",$2-25,"\t",$2+25}' > ${BEDs}/${fname}_regions.bed
	done
	
fi