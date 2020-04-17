#!/bin/bash

USAGE="mutect_cleanup.sh\tvcf_file"

if [ -z "$1" ];then printf "$USAGE"; exit 1; fi

