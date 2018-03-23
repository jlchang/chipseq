######################
#
#  collectExptMetrics.sh
#
#  collect metrics from all samples in input_data.tsv into _metrics.tsv file 
#
######################

#!/bin/bash

#check PIPE_LOC environment variable is set
#https://stackoverflow.com/questions/307503
: "${PIPE_LOC:?Need to set PIPE_LOC non-empty}"

SCRIPTDIR="/cil/shed/apps/internal/chipseq/$PIPE_LOC"

if [  ! -d "$SCRIPTDIR" ]
  then
    echo "Unable to find $SCRIPTDIR, please check the provided PIPE_LOC value"
    exit
fi

orig=`pwd`
suffix=$(basename $orig)
type=$(basename $(dirname $orig))
ssf=$(basename $(dirname $(dirname $orig)))
expt=${ssf}_${type}_${suffix}

result=${expt}_metrics.tsv


if [ -e ${result} ]
  then
    echo "metrics file already exists, try again after you:"
    echo "rm ${result}"
    exit 1
fi


set -e
echo "collecting metrics from samples in $orig"


cp ${SCRIPTDIR}/metrics_header.txt ${result}

while IFS=$'\t': read sample fastq1 fastq2
do
#  echo "collect metrics for ${orig}/${sample}_PE/${sample}.Metrics"
  metrics=$(tail -n1 ${orig}/${sample}_PE/${sample}.Metrics)
  echo -ne "$expt\t" >> ${result}
  echo -ne "$sample\t" >> ${result}
  echo -ne "$(grep $sample control_info.txt | cut -f 2)\t" >> ${result}
  echo "$metrics" >> ${result}
done < input_data.tsv

