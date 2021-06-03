#!/bin/bash

for f in *filtered.vcf
do
	fa=`basename $f filtered.vcf`
	grep PASS $f > ${fa}true.vcf
done

for f in *filtered.vep
do
	fa=`basename $f filtered.vep`
	awk '/#|PASS/' $f > ${fa}true.vep
done

for f in *VEPannotated.vcf
do
	fa=`basename $f VEPannotated.vcf`
	awk '/#|PASS/' $f > ${fa}INDELfiltered.vcf
	rm $f
done