#!/bin/bash

source ~/.condainit
conda activate java11
cd /oasis/tscc/scratch/jad054/mpn/
num=$1

score-client download --manifest /oasis/tscc/scratch/jad054/mpn/manifest_split/manifest_${num} --output-dir /oasis/tscc/scratch/jad054/mpn/bams/

