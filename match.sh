for f in *_2outof4_bseq_igv.vcf;do
fa=`basename $f _2outof4_bseq_igv.vcf`;
awk -F "\t" 'NR==FNR{a[$1$2$3$4$5]=$8;next} NR>FNR{if($1$2$3$4$5 in a){OFS="\t";if($6=="."){$6="mt"}else{$6=$6",mt"};print $0"\t"a[$1$2$3$4$5]}else{OFS="\t";print $0"\t."}}' ../mutect_snvs/${fa}_mutect_snv.vcf $f>${fa}_match1.vcf

awk -F "\t" 'NR==FNR{a[$1$2$3$4$5]=$8;next} NR>FNR{if($1$2$3$4$5 in a){OFS="\t";if($6=="."){$6="vs"}else{$6=$6",vs"};print $0"\t"a[$1$2$3$4$5]}else{OFS="\t";print $0"\t."}}' ../varscan_snvs/${fa}_varscan_snv.vcf ${fa}_match1.vcf>${fa}_match2.vcf

awk -F "\t" 'NR==FNR{a[$1$2$3$4$5]=$8;next} NR>FNR{if($1$2$3$4$5 in a){OFS="\t";if($6=="."){$6="st"}else{$6=$6",st"};print $0"\t"a[$1$2$3$4$5]}else{OFS="\t";print $0"\t."}}' ../strelka_snvs/${fa}_strelka_snv.vcf ${fa}_match2.vcf>${fa}_match3.vcf

awk -F "\t" 'NR==FNR{a[$1$2$3$4$5]=$8;next} NR>FNR{if($1$2$3$4$5 in a){OFS="\t";if($6=="."){$6="ms"}else{$6=$6",ms"};print $0"\t"a[$1$2$3$4$5]}else{OFS="\t";print $0"\t."}}' ../muse_snvs/${fa}_muse_snv.vcf ${fa}_match3.vcf>${fa}_match4.vcf

cat ${fa}_match4.vcf|awk '{OFS="\t";a=substr($8,3);$8=a"|"$12"|"$13"|"$14;print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11}'|
awk -F"\t" '{
		OFS=FS;
		split($10,n,":");
		split($11,t,":");
		ndep=n[1]+n[2]+n[3]+n[4]+n[5]+n[6]+n[7]+n[8]
		tdep=t[1]+t[2]+t[3]+t[4]+t[5]+t[6]+t[7]+t[8]
		if($4=="A"){
			Rfn=n[1]
			Rrn=n[5]
			nrd=n[1]+n[5]
			trd=t[1]+t[5]	
		}
		else if($4=="C"){
			Rfn=n[2]
			Rrn=n[6]
			nrd=n[2]+n[6]
			trd=t[2]+t[6]		
		}
		else if($4=="G"){
			Rfn=n[3]
			Rrn=n[7]
			nrd=n[3]+n[7]
			trd=t[3]+t[7]
		}
		else if($4=="T"){
			Rfn=n[4]
			Rrn=n[8]
			nrd=n[4]+n[8]
			trd=t[4]+t[8]
		}
		if($5=="A"){
			Aft=t[1]
			Art=t[5]
			vaf=(tdep==0?0:(t[1]+t[5])/tdep)
			nvaf=(ndep==0?0:(n[1]+n[5])/ndep)
			nad=n[1]+n[5]
			tad=t[1]+t[5]
		}
		else if($5=="C"){
			Aft=t[2]
			Art=t[6]
			vaf=(tdep==0?0:(t[2]+t[6])/tdep)
			nvaf=(ndep==0?0:(n[2]+n[6])/ndep)
			nad=n[2]+n[6]
			tad=t[2]+t[6]
		}
		else if($5=="G"){
			Aft=t[3]
			Art=t[7]
			vaf=(tdep==0?0:(t[3]+t[7])/tdep)
			nvaf=(ndep==0?0:(n[3]+n[7])/ndep)
			nad=n[3]+n[7]
			tad=t[3]+t[7]
		}
		else if($5=="T"){
			Aft=t[4]
			Art=t[8]
			vaf=(tdep==0?0:(t[4]+t[8])/tdep)
			nvaf=(ndep==0?0:(n[4]+n[8])/ndep)
			nad=n[4]+n[8]
			tad=t[4]+t[8]
		}
		$10=$10":"nrd":"nad":"nvaf
		$11=$11":"trd":"tad":"vaf
		print}' >${fa}_bseq_igv_annotated.vcf
done
rm *match*vcf
