#!/bin/bash
#Frances Keer

#makes bedgraph for the input minibam that has total reads per bin, foward reads per bin, and reverse reads per bin. 
#input absolute path to minibam
#must be in cvc_py3 environment


bamCoverage -b $1 --filterRNAstrand forward --binSize 50 --skipNAs -of bedgraph -o fwd

bamCoverage -b $1 --filterRNAstrand reverse --binSize 50 --skipNAs -of bedgraph -o rev

bamCoverage -b $1 --binSize 50 --skipNAs -of bedgraph -o tot

name=$(echo $1 | awk -F "/" '{print $NF}' | cut -f 1 -d '.')
while read line;do

	bin1=$(echo $line | cut -f 1 -d ' ')
	bin2=$(echo $line | cut -f 2 -d ' ')
	bin3=$(echo $line | cut -f 3 -d ' ')
	tcount=$(echo $line | cut -f 4 -d ' ')
	

	f=$(grep -w $bin1 fwd | grep -w $bin2 | grep -w $bin3)
	r=$(grep -w $bin1 rev | grep -w $bin2 | grep -w $bin3)
	fcount=$(echo $f | cut -f 4 -d ' ')
	rcount=$(echo $r | cut -f 4 -d ' ')
	

	if [ -z "$fcount" ];then
		fcount=0
	fi
	if [ -z "$rcount" ];then
		rcount=0
	fi

	echo -e $bin1 "\t" $bin2 "\t" $bin3 "\t" $tcount "\t" $fcount "\t" $rcount "\n" >> $name_combined.bedgraph

	fcount=$()
	rcount=$()

done < tot


rm tot
rm fwd
rm rev
