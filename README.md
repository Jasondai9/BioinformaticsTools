# A collection of short scripts for use with the ConsensusVariantCaller pipeline
Authors: Jason Dai, Frances Keer, Yuzhou (Evelyn) Tong

# BAM check
Checks the flagstat files for each BAM file in the current directory and prints out stats for either all of the files or just the ones that may be problematic (default).  
* Problematic means there are less than 1000 passed reads or positive failed reads  
### Usage 
To view all:
> cd /path/to/bams  
> bam_check all  

To view problematic (default):  
> cd /path/to/bams  
> bam_check  

# BAM2FQ PBS File Generator
Generated PBS files that when run will convert BAM files to FASTQ files  
* PBS files will be put in current directory  
### Usage 
> bam2fq_pbs_gen.sh \
> path/to/fastq \
> path/to/bams \
> email

# FASTQC Check
Checks the quality of a directory of fastqc.html files and outputs warnings/errors  
* Must be called from within the directory containing fastqc files
* Place the shell script in ~/miniconda3/bin
### Usage
1. cd to the directory containing fastqc files  
2. fastqc_check  

# BAM to FASTQ
Converts a directory containing BAMs to fastq
* If the BAM file is large, use the PBS generator and submit that instead
* Must have samtools installed  
### Usage
> bam_convert.sh \  
> path/to/fastq \  
> path/to/bam  

# CVC Script Generator
Generates a script to run CVC
* This will output to std:out, so you should redirect output into your script.sh  
* Cancersample.txt files will need to be changed manually  
> ex: CVC_script_generator.sh panel_of_normals 27601661 lung jung > /path/to/submits/27601661_lung_pon.sh"
### USAGE 
> CVC_script_generator.sh \\  
> [alignment/panel_of_normals/variant_calling/all] \\  
> pmid \\  
> tissue_type \\  
> author_name  

# Alignment Check
Checks to make sure there are enough files generated in the bam folder for each sample, ie each sample should have 10 files associated with it. It will also check to make sure the bam files are larger than 1GB and that the final bam files are larger than the bam files. It puts the samplew that do not have enough files and the samples that are too small into problems.txt. It also creates names_bad_samples.txt so you can more easily identify which samples failed. 
* Must be called when inside the bam folder
### Usage
> align_check.sh name_of_submit_folder

# Number of Normals
Checks to make sure that the number of normals matches the number of PONs generated, eg are there enough PONs for that batch. If there are enough PONs, the combined PON will be generated
* Must be called when inside the PON folder
### Usage
> num_norms.sh name_of_submit_folder

# Delete jobs
Will delete all jobs within the range of the job IDs provided. 
### Usage
> del_jobs.sh lower_lim upper_lim

# Count Variants
Will count and display variants for all merged vcfs. Displays SNVs and indels separately.
* Must be called when inside the consensus_vcf folder
### Usage
> count_vc.sh

# BamCoverage Strand Identification
Will calculate total coverage, forward coverage, and reverse coverage for the input minibam. Output a file called combined.bedgraph that is structured as such:
chr#  bin_start bin_end total_coverage  fwd_coverage  rev_coverage

## Important!
* In order to use this script, you must git clone from: https://github.com/deeptools/deepTools.git
* You must then proceed to bedtools/bedtools/writeBedGraph.py
* On both line 245 and line 252, there are three quotation marks ( """ ), delete these (uncommenting that section of code)
* Proceed to the top level of the deepTools repository and enter in your command line: pip install -e .
* Add to your ~/.bashrc: export PATH="/deepTools/bin:$PATH" 
* Make sure that you don't have deeptools installed from conda in the python environment you will be in while running this script

### Usage
> bamCoverage_strands.sh /absolute/path/to/mini.bam
