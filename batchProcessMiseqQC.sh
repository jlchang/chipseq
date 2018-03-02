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
	

# if no arguments supplied, display usage 
if [  $# -lt 1 ] 
then 
    display_usage
    exit 1
fi

ssf=$"{1}"
version=$"{2}"

#check if supplied path exists
if [  ! -d "$3" ]
then
    echo "Unable to find $3, please check the provided path"
    exit
else
    datapath=$"{3}"
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
        chipdir="${4}"
        echo "creating analysis directory in optional output location: $chipdir"
    fi
fi

echo "checking ${chipdir}/${ssf}/miseq/${version}"

if [ -e ${chipdir}/${ssf}/miseq/${version} ]
  then
    echo "An analysis directory already exists for ${ssf}/miseq/${version}, exiting"
    exit
fi




#check if fastq files exist at supplied path

if stat -t ${datapath}/*_R1_001.fastq.gz >/dev/null 2>&1
then
    count=$(ls -1 ${datapath}/*_R1_001.fastq.gz | grep -v Undetermined | wc -l)
    echo "found $count samples at "
else
    echo "no fastq found at $datapath"
    exit
fi


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

runFolder=$(basename $(dirname $(dirname $(dirname "$(cat dataPath)"))))
flowcell=$(echo "$runFolder" | awk -F"-" '{print $NF}')
