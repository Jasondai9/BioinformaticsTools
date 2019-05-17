#!/bin/bash
#Frances Keer

#usage: bash del_jobs.sh lower_limit_of_job_IDs upperlimit_of_job_IDs
#will delete all jobs within the limits provided

for i in $(eval echo "{$1..$2}")
do
  	qdel $i
done
