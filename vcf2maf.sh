#!/bin/bash
#Jason Dai

if [ "$1" == "" ] || [ "$2" == "" ]; then
	printf "\nUSAGE: vcf2maf.sh vcf maf"

else
	input=$1
	output=$2

printf "Hugo_Symbol\tEntrez_Gene_Id\tCenter\tNCBI_Build\tChromosome\tStart_Position\tEnd_Position\tStrand\tVariant_Classification\tVariant_Type\tReference_Allele\tTumor_Seq_Allele1\tTumor_Seq_Allele2\tdbSNP_RS\tdbSNP_Val_Status\tTumor_Sample_Barcode\n" > $output

	grep -v "intergenic_variant" $input | awk '{if ($12 ~ "protein_altering_variant") variant_classification="protein_altering_variant";
	else if ($12 ~ "missense_variant") variant_classification="Missense_Mutation"; 
	else if ($12 ~ "inframe_deletion") variant_classification="In_Frame_Del"; 
	else if ($12 ~ "inframe_insertion") variant_classification="In_Frame_Ins"; 
	else if ($12 ~ "splice_donor_variant") variant_classification="Splice_Site"; 
	else if ($12 ~ "splice_acceptor_variant") variant_classification="Splice_Site"; 
	else if ($12 ~ "transcript_amplification") variant_classification="transcript_amplification"; 
	else if ($12 ~ "start_lost") variant_classification="Translation_Start_Site"; 
	else if ($12 ~ "stop_lost") variant_classification="Nonstop_Mutation";
	else if (($12 ~ "frameshift_variant") && (length($4) < length($5))) variant_classification="Frame_Shift_Ins"; 
	else if (($12 ~ "frameshift_variant") && (length($4) > length($5))) variant_classification="Frame_Shift_Del"; 
	else if ($12 ~ "stop_gained") variant_classification="Nonsense_Mutation"; 
	else if ($12 ~ "transcript_ablation") variant_classification="transcript_ablation"; 
	else variant_classification="."
	} {if (length($4) > length($5)) variant_type="DEL"; else if (length($4) < length($5)) variant_type="INS"; else variant_type="SNP" } {print $14"\t.\t.\tGRCh38\t"$1"\t"$2"\t"$2+length($4)-1"\t+\t"variant_classification"\t"variant_type"\t"$4"\t"$4"\t"$5"\t"$3"\t.\t"$6}' | awk '{ if ( $9 != "." ) print }' | sed 's/chr//g' >> $output

fi