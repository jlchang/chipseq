######################
#
#  batchProcessMiseqQC.sh
#
#  setup Miseq run for ChIPseq QC
#
######################


#!/usr/bin/env bash

display_usage() { 
	echo -e "\nUsage: $0 <SSF-#> <version> <dataPath> <optional:output path>\n" 
	echo "expected path format: /btl/data/MiSeq0/runs/ChIPSeq/<run folder>/Data/Intensities/BaseCalls"
	echo
	} 

source /broad/software/scripts/useuse
use UGER

# if no arguments supplied, display usage 
if [  $# -lt 1 ] 
then 
    display_usage
    exit 1
fi

ssf=$1
version=$2

#check if supplied path exists
if [  ! -d "$3" ]
then
    echo "Unable to find $3, please check the provided path"
    exit
else
    datapath=$3
fi


#check if optional output path supplied
if [  $# -lt 4 ]
then
    chipdir="/btl/analysis/ChIPseq/mapq1"
else
    if [  ! -d "$4" ]
    then
        echo "Unable to find $4, please check the provided optional output path"
        exit
    else
        chipdir=$4
        echo "creating analysis directory in optional output location: $chipdir"
    fi
fi

echo "checking ${chipdir}/${ssf}/miseq/${version}"

if [ -e ${chipdir}/${ssf}/miseq/${version} ]
  then
    echo "An analysis directory already exists at ${chipdir}/${ssf}/miseq/${version}, exiting"
    exit
fi

#check if fastq files exist at supplied path

if stat -t ${datapath}/*_R1_001.fastq.gz >/dev/null 2>&1
then
    count=$(ls -1 ${datapath}/*_R1_001.fastq.gz | grep -v Undetermined | wc -l)
    echo "found $count samples at $datapath"
else
    echo "no fastq found at $datapath"
    exit
fi

echo "running analysis in ${chipdir}/${ssf}/miseq/${version}"

source /broad/software/scripts/useuse
reuse -q .java-jdk-1.8.0_121-x86-64
reuse -q .r-3.3.0

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

#check PIPE_LOC environment variable is set
#https://stackoverflow.com/questions/307503
: "${PIPE_LOC:?Need to set PIPE_LOC non-empty}"

SCRIPTDIR="/cil/shed/apps/internal/chipseq/$PIPE_LOC"

if [  ! -d "$SCRIPTDIR" ]
  then
    echo "Unable to find $SCRIPTDIR, please check the provided PIPE_LOC value"
    exit
fi

export PIPE_LOC=$PIPE_LOC

mkdir -p ${chipdir}/${ssf}/miseq/${version}
cd ${chipdir}/${ssf}/miseq/${version}

echo "$datapath" > ${chipdir}/${ssf}/miseq/${version}/dataPath

$SCRIPTDIR/createMiseqInputFile.sh  $datapath

qsub -cwd -v PIPE_LOC -N MQBC_${ssf} -l h_vmem=4G -l h_rt=6:00:00 $SCRIPTDIR/assessMiseqMeanQualityByCycle.sh $datapath ${ssf}_miseq_${version}

for i in $(cut -f 1 input_data.tsv); do echo -e "$i\tno"; done > control_info.txt

$SCRIPTDIR/runUGESPairedAMrsc.sh > submit.out

echo "manually tag control samples in input_data.tsv file"
echo "add expt date to /btl/analysis/ChIPseq/mapq1/analysis/ssf_date.tsv"

