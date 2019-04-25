# FASTQC Check
Checks the quality of a directory of fastqc.html files and outputs warnings/errors  
* Must be called from within the directory containing fastqc files
* Place the shell script in ~/miniconda3/bin
### Usage
1. cd to the directory containing fastqc files  
2. fastqc_check  
# BAM to FASTQ
Converts a directory containing BAMs to fastq
* Must be called from within the directory containing BAM files  
* If the BAM file is large, submit a job  
* Must have samtools installed  
* Fastq files will be created in the same directory  

### Usage
1. cd to the directory containing BAM files  
2. Run bam_convert.sh  
