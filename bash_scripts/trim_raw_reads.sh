#!/bin/bash

{
usage="$(basename "$0") [-h] [-l <SRA_list>]
Script to perform raw read preprocessing using fastp
    -h show this help text
    -l path/file to tab-delimitted sra list"
options=':hl:'
while getopts $options option; do
    case "$option" in
        h) echo "$usage"; exit;;
	l) l=$OPTARG;;
	:) printf "missing argument for -%s\n" "$OPTARG" >&2; echo "$usage" >&2; exit 1;;
       \?) printf "illegal option: -%s\n" "$OPTARG" >&2; echo "$usage" >&2; exit 1;;
     esac
done

# mandatory arguments
if [ ! "$l" ]; then
    echo "argument -l must be provided"
    echo "$usage" >&2; exit 1
fi

begin=`date +%s`

echo "load required modules"
module load fastp/0.20.1
module load sra-toolkit/3.0.2

echo "Downloading SRA files from the given list of accessions"
prefetch --max-size 800G -O ./ --option-file ${l}
echo "SRA files were downloaded in current directory"
echo ""
echo "Done"

##################################################################################
# Trimming downloaded Illumina datasets with fastp, using 16 threads (-w option) #
##################################################################################

echo "Trimming downloaded Illumina datasets with fastp."
echo ""



}
