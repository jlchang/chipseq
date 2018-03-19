#!/bin/bash

source /broad/software/scripts/useuse
reuse -q UGES

set -e

#check PIPE_LOC environment variable is set
#https://stackoverflow.com/questions/307503
: "${PIPE_LOC:?Need to set PIPE_LOC non-empty}"

SCRIPTDIR="/cil/shed/apps/internal/chipseq/$PIPE_LOC"

if [  ! -d "$SCRIPTDIR" ]
then
    echo "Unable to find $SCRIPTDIR, please check the provided PIPE_LOC value"
    exit
fi

currDir=$(pwd)
echo "current Directory is $currDir"
fastq="$currDir/fastq"

if [ -d $currDir/fastq ]
then
    echo "output dir exists:"
    echo "rmdir $currDir/fastq"
  exit
fi

if [ ! -d seq_prep ]
then
    echo "missing seq_prep dir, please check that all lanes contain the same samples before proceeding"
    exit
fi


echo "making $fastq"
mkdir $fastq

path=$(cat fastqPath)
echo "obtain data from $path"

while IFS=$'\t': read barcode1 barcode2 sampleName
do
  echo "qsub -q btl -cwd -o seq_prep -e seq_prep $SCRIPTDIR/aggregateFastqs.sh $fastq $path $barcode1 $barcode2 $sampleName"
  qsub -q btl -cwd -o seq_prep -e seq_prep $SCRIPTDIR/aggregateFastqs.sh $fastq $path $barcode1 $barcode2 $sampleName
done  < barcode_mapping.txt
