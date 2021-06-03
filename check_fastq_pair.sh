#!/bin/bash

samples=$(cat $1)
#samples should be the sample name until the _1 or _2

for f in $samples
do
	#both paired fq dont have same num reads
	if [ ! $(cat ${f}_1*paired.fq | wc -l) -eq $(cat ${f}_2*paired.fq | wc -l) ]
	then
		echo different num reads in $f
	fi

	if [ $(tail -n4 ${f}_1*paired.fq | head -n1) != $(tail -n4 ${f}_2*paired.fq | head -n1) ]
	then
		echo $f has different read names
	fi
done