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

echo "create file storing environment"
mkdir -p sra_files
mkdir -p raw_reads
mkdir -p clean_reads

echo "Downloading SRA files from the given list of accessions"
cd sra_files
prefetch --max-size 800G -O ./ --option-file ../${l}
ls -p | grep SRR > sra_list
cd ..
echo "SRA files were downloaded in current directory"
echo ""

echo "Getting fastq files from SRA files"
while read i; do \
	cd "$i" \
	fastq-dump --split-files --gzip sra_files/"$i"/"$i".sra \ 
	# the --split-files option is needed for PE data
	mv "$i"*.fastq.gz ../raw_reads/ \
	cd ..
done<sra_files/sra_list
echo "Done"

####################################################
# Trimming downloaded Illumina datasets with fastp #
####################################################

echo "Trimming downloaded Illumina datasets with fastp."

ls *.fastq.gz | cut -d "." -f "1" | cut -d "_" -f "1" | sort | uniq > fastq_list
while read z ; do \
	cd raw_reads
	fastqc ${z}_1.fastq.gz
	fastqc ${z}_2.fastq.gz
	fastp -i ${z}_1.fastq.gz -I ${z}_2.fastq.gz \ # insert description here
	-e 25 \ # insert description here
	-q 15 \ # insert description here
	-u 40 \ # insert description here
	-l 15 \ # insert description here
	--adapter_sequence AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \ # insert description here
	--adapter_sequence_r2 AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \ # insert description here
	-M 20 -W 4 -5 -3 \ # insert description here
	-c \ # insert description here
	-m --merged_out ../cleaned_reads/${z}_merged.fastq \ # insert description here
	--out1 ../cleaned_reads/${z}_unpaired1_passed.fastq \ # insert description here
	--out2 ../cleaned_reads/${z}_unpaired2_passed.fastq \ # insert description here
	--unpaired1 ../cleaned_reads/${z}_unpaired1_failed.fastq \ # insert description here
	--unpaired2 ../cleaned_reads/${z}_unpaired2_failed.fastq # insert description here 
gzip ${z}_merged.fastq
done<fastq_list
echo ""



}
