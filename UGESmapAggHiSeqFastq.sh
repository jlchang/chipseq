#!/bin/bash

source /broad/software/scripts/useuse
reuse -q UGES

set -e

currDir=$(pwd)
echo "current Directory is $currDir"
fastq="$currDir/fastq"
echo "making $fastq"
mkdir $fastq

path=$(cat fastqPath)
echo "obtain data from $path"

while IFS=$'\t': read barcode1 barcode2 sampleName
do
  echo "qsub -q btl /cil/shed/apps/internal/chipseq/prod/aggregateFastqs.sh $fastq $path $barcode1 $barcode2 $sampleName"
  qsub -q btl /cil/shed/apps/internal/chipseq/prod/aggregateFastqs.sh $fastq $path $barcode1 $barcode2 $sampleName
done  < barcode_mapping.txt
