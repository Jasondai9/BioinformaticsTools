#!/bin/bash

#remove the anchor base for all indel vcfs in current dir and store temp files in old/
for f in *.vcf; do awk 'length($5)>1 {print $1"\t"$2"\t"$3"\t-\t"substr($5,2)"\t.\t"$7}' $f | grep -v "#" > $(basename $f .vcf).ins;done
for f in *.vcf; do awk 'length($4)>1 {print $1"\t"$2"\t"$3"\t"substr($4,2)"\t-\t.\t"$7}' $f | grep -v "#" > $(basename $f .vcf).del;done
mkdir old
mv * old
cd old
for f in *.ins; do cat $(basename $f .ins).del $f > ../$(basename $f .ins).vcf;done