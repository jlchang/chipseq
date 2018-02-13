######################
#
#  assessMiseqMeanQualityByCycle.sh
#
#  run MeanQualityByCycle for Miseq run and report cycles <Q30
#
######################


#!/usr/bin/env bash

SCRIPTDIR="/cil/shed/apps/internal/chipseq/dev/v0.06"

display_usage() { 
	echo -e "\nUsage: $0 <path> <optional:output file prefix> \n" 
	echo "expected path format: /btl/data/MiSeq0/runs/ChIPSeq/<run folder>/Data/Intensities/BaseCalls"
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

#check if output prefix supplied
if [  $# -lt 2 ]
then
    output_prefix=""
else
    echo "using $2 as prefix for output files"
    output_prefix="${2}_"
fi

#check if fastq files exist at supplied path

if stat -t ${1}/*_R1_001.fastq.gz >/dev/null 2>&1
then
    count=$(ls -1 ${1}/*_R1_001.fastq.gz | wc -l)
    echo "concatenating $count fastq files"
else
    echo "no fastq found at $1"
    exit
fi


source /broad/software/scripts/useuse
reuse -q .java-jdk-1.8.0_121-x86-64
reuse -q .r-3.3.0

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

#cat ${dataPath}/*_R1_001.fastq.gz > R1_001.fastq.gz
#cat ${dataPath}/*_R2_001.fastq.gz > R2_001.fastq.gz
java -Xmx4G -jar /seq/software/picard-public/2.14.0/picard.jar FastqToSam \
	F1=R1_001.fastq.gz \
	F2=R2_001.fastq.gz \
	O=unaligned.bam \
	SM=MQBC

java -Xmx4G -jar /seq/software/picard-public/2.14.0/picard.jar  MeanQualityByCycle \
	I=unaligned.bam \
	O=${output_prefix}unalignedBam_mean_qual_by_cycle.txt \
	CHART=${output_prefix}unalignedBam_mean_qual_by_cycle.pdf

rm unaligned.bam
Rscript $SCRIPTDIR/identifyMeanQualityByCycles.R "${output_prefix}" > ${output_prefix}_below_30_qual_by_cycle_report.txt
