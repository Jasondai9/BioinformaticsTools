for f in *_2outof3_igv.vcf;do
fa=`basename $f _2outof3_igv.vcf`;

mutectcall=$(wc -l ../mutect_indels/${fa}_mutect_indel.vcf | cut -d' ' -f1)
varscancall=$(wc -l ../varscan_indels/${fa}_varscan_indel.vcf | cut -d' ' -f1)
strelkacall=$(wc -l ../strelka_indels/${fa}_strelka_indel.vcf | cut -d' ' -f1)
if [ $mutectcall -eq 0 ]
then
	awk -F "\t" '{OFS="\t";$8=$8"|.";print $0}' $f>${fa}_match1.vcf;
else
	awk -F "\t" 'NR==FNR{a[$1$2$3$4$5]=$8;next} NR>FNR{if($1$2$3$4$5 in a){OFS="\t"; if($6=="."){$6="mt"}else{$6=$6",mt"};$8=$8"|"a[$1$2$3$4$5];print $0}else{OFS="\t";$8=$8"|.";print $0}}' ../mutect_indels/${fa}_mutect_indel.vcf $f>${fa}_match1.vcf
fi

if [ $varscancall -eq 0 ]
then
	awk -F "\t" '{OFS="\t";$8=$8"|.";print $0}' ${fa}_match1.vcf>${fa}_match2.vcf;
else
	awk -F "\t" 'NR==FNR{a[$1$2$3$4$5]=$8;next} NR>FNR{if($1$2$3$4$5 in a){OFS="\t"; if($6=="."){$6="vs"}else{$6=$6",vs"};$8=$8"|"a[$1$2$3$4$5];print $0}else{OFS="\t";$8=$8"|.";print $0}}' ../varscan_indels/${fa}_varscan_indel.vcf ${fa}_match1.vcf>${fa}_match2.vcf
fi

if [ $strelkacall -eq 0 ]
then
	awk -F "\t" '{OFS="\t";$8=$8"|.";print $0}' ${fa}_match2.vcf>${fa}_match3.vcf
else
	awk -F "\t" 'NR==FNR{a[$1$2$3$4$5]=$8;next} NR>FNR{if($1$2$3$4$5 in a){OFS="\t"; if($6=="."){$6="st"}else{$6=$6",st"};$8=$8"|"a[$1$2$3$4$5];print $0}else{OFS="\t";$8=$8"|.";print $0}}' ../strelka_indels/${fa}_strelka_indel.vcf ${fa}_match2.vcf>${fa}_match3.vcf
fi

cat ${fa}_match3.vcf | awk -F"\t" '{
		OFS=FS;
		split($10,n,":")
		split($11,t,":")
		if(length($4) < length($5)){
			indel="INS"
		} else {
			indel="DEL"
		}
		if(indel=="INS"){
			if($4=="A"){
				nPosRef=n[1]
				nNegRef=n[8]
				tPosRef=t[1]
				tNegRef=t[8]
			}
			else if($4=="C"){
				nPosRef=n[2]
				nNegRef=n[9]
				tPosRef=t[2]
				tNegRef=t[9]
			}
			else if($4=="G"){
				nPosRef=n[3]
				nNegRef=n[10]
				tPosRef=t[3]
				tNegRef=t[10]
			}
			else if($4=="T"){
				nPosRef=n[4]
				nNegRef=n[11]
				tPosRef=t[4]
				tNegRef=t[11]
			}
			nRefDepth=nPosRef+nNegRef
			tRefDepth=tPosRef+tNegRef
			nPosAlt=n[7]
			nNegAlt=n[14]
			tPosAlt=t[7]
			tNegAlt=t[14]
			nAltDepth=nPosAlt+nNegAlt
			tAltDepth=tPosAlt+tNegAlt
		}
		else {
			if(substr($4, 2, 1)=="A"){
				nPosRef=n[1]
				nNegRef=n[8]
				tPosRef=t[1]
				tNegRef=t[8]
			}
			else if(substr($4, 2, 1)=="C"){
				nPosRef=n[2]
				nNegRef=n[9]
				tPosRef=t[2]
				tNegRef=t[9]
			}
			else if(substr($4, 2, 1)=="G"){
				nPosRef=n[3]
				nNegRef=n[10]
				tPosRef=t[3]
				tNegRef=t[10]
			}
			else if(substr($4, 2, 1)=="T"){
				nPosRef=n[4]
				nNegRef=n[11]
				tPosRef=t[4]
				tNegRef=t[11]
			}
			nRefDepth=nPosRef+nNegRef
			tRefDepth=tPosRef+tNegRef
			nPosAlt=n[6]
			nNegAlt=n[13]
			tPosAlt=t[6]
			tNegAlt=t[13]
			nAltDepth=nPosAlt+nNegAlt
			tAltDepth=tPosAlt+tNegAlt
		}
		nTotalDepth=n[1]+n[2]+n[3]+n[4]+n[5]+n[6]+n[7]+n[8]+n[9]+n[10]+n[11]+n[12]+n[13]+n[14]
		tTotalDepth=t[1]+t[2]+t[3]+t[4]+t[5]+t[6]+t[7]+t[8]+t[9]+t[10]+t[11]+t[12]+t[13]+t[14]
		nvaf=(nTotalDepth==0?0:nAltDepth/nTotalDepth)
		tvaf=(tTotalDepth==0?0:tAltDepth/tTotalDepth)
		$10=$10":"nRefDepth":"nAltDepth":"nvaf
		$11=$11":"tRefDepth":"tAltDepth":"tvaf
		print
		}' >${fa}_igv_annotated.vcf

done
rm *match*vcf
