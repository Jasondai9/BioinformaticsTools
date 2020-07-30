#!/bin/bash
#Jason Dai

#uses GNU parallel to generate index of a directory of bams

BAMS=$1

parallel samtools index ::: "$BAMS"
