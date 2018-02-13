######################
#
#  assessHiseqMeanQualityByCycle.sh
#
#  run MeanQualityByCycle for Hiseq lane and report cycles <Q30
#
######################


#!/usr/bin/env bash

display_usage() { 
	echo -e "\nUsage: $0 <path> <optional:output file prefix> \n" 
	echo "expected path format: /btl/data/walkup/ChIPSeq/SSF-#/data/<flowcell>/<run folder>/<lane>"
	echo
	} 
	

# if no arguments supplied, display usage 
	if [  $# -lt 1 ] 
	then 
		display_usage
		exit 1
	fi 

#check if supplied path exists
if [  ! -d "$1" ]
  then
    echo "Unable to find $1, please check the provided path"
    exit
else
    dataPath=$1
fi

#check if fastq files exist at supplied path
lane=$(basename "$1")
sansLane=$(dirname "$1")
sansFolder=$(dirname $sansLane)
flowcell=$(basename "$sansFolder")

if [ ! -e ${dataPath}/${flowcell}.${lane}.1.fastq.gz ]
then
    echo "${flowcell}.${lane}.1.fastq.gz not found at $1"
    exit
fi

#check if output prefix supplied
if [  $# -lt 2 ]
then
    output_prefix=""
else
    output_prefix="${2}_${flowcell}_${lane}_"
    echo "using ${output_prefix} as prefix for output files"
fi

source /broad/software/scripts/useuse
reuse -q .java-jdk-1.8.0_121-x86-64
reuse -q .r-3.3.0

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace



java -Xmx4G -jar /seq/software/picard-public/2.14.0/picard.jar FastqToSam \
	F1=${dataPath}/${flowcell}.${lane}.1.fastq.gz \
	F2=${dataPath}/${flowcell}.${lane}.2.fastq.gz \
	O=unaligned.bam \
	SM=MQBC

java -Xmx4G -jar /seq/software/picard-public/2.14.0/picard.jar  MeanQualityByCycle \
	I=unaligned.bam \
	O=${output_prefix}unalignedBam_mean_qual_by_cycle.txt \
	CHART=${output_prefix}unalignedBam_mean_qual_by_cycle.pdf

rm R1_001.fastq.gz
rm R2_001.fastq.gz
rm ${output_prefix}unaligned.bam
Rscript $SCRIPTDIR/identifyMeanQualityByCycles.R "${output_prefix}" > ${output_prefix}_below_30_qual_by_cycle_report.txt
