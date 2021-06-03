#!/bin/bash

# remove -n to actually run. -n is dry run
rsync -av --ignore-existing --exclude '.archive' --exclude '*.bam' --exclude 'mpileup' --exclude '*.bai' --exclude 'strelka/workspace' --exclude '*.mpileup' /restricted/alexandrov-group/shared/precancer_analysis/new_analysis/ /projects/ps-lalexandrov/shared/Precancer_analysis_results