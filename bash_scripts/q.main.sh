#!/bin/sh
#SBATCH --account=utu-biol4310
#SBATCH --partition=lonepeak
#SBATCH --nodes=1
#SBATCH --mem=16
#SBATCH --ntasks=1
#SBATCH -o slurm-%j.out-%N
#SBATCH -e slurm-%j.err-%N

wd=~/BIOL_4310/Exercises/Exercise_4/trimming_raw_reads
cd $wd
bash bash_scripts/trim_raw_reads.sh -l raw_reads_SRA_list.txt -wd $wd
