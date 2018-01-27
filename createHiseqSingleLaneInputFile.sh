#!/bin/bash

#####
#
# createHiseqInputFile.sh <path> 
# 
# given path (to library_params.txt, demultiplexing_library_params.txt & fastq),
#     obtain samplename and fastq path prefix create input_data.tsv
#     for Hiseq that does not need fastq aggregation
#
#####


# Any subsequent commands which fail will cause the shell script to exit immediately
set -e

dirPath=$1

if [  ! -d "$dirPath" ]
  then
    echo "Unable to find $dirPath, please check the provided path"
    exit
fi

if [  -e "input_data.tsv" ]
  then
    echo "input_data.tsv exists"
    exit
fi

tail -n +3 $1/demultiplexing_library_params.txt | cut -f 1 > prefix
tail -n +3 $1/library_params.txt | cut -f 4 > sample


paste sample prefix > sampre

while IFS=$'\t': read sam pre
do
    echo "$sam	${pre}.1.fastq.gz	${pre}.2.fastq.gz" >> input_data.tsv
done < sampre
rm sample prefix sampre
echo "input_data.tsv created"
