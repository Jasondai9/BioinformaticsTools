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
* If the BAM file is large, submit a job  
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
> \> script.sh
