######################
#
#  makeRinputFiles.sh
#
#  collect metrics files for R processing
#
######################

#!/bin/bash

# set to print each command and exit script if any command fails
set -euo pipefail

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

if [ -e all.metrics ]
  then
    echo "metrics file already exists, try again after you:"
    echo "rm ${orig}/all.metrics"
    exit
fi

cp ${SCRIPTDIR}/metrics_header.txt all.metrics


for i in $(ls -1 /btl/analysis/ChIPseq/mapq1/*-*/[hm]iseq/*/*_metrics.tsv)
do
    tail -n +2 $i | cut -f 1-22 >> all.metrics
done

echo "experiments in all.metrics:"
cut -f 1 all.metrics | uniq

cp ${SCRIPTDIR}/metrics_header.txt hiseq.metrics

for i in $(ls -1 /btl/analysis/ChIPseq/mapq1/*-*/hiseq/*/*_metrics.tsv)
do
    tail -n +2 $i | cut -f 1-22 >> hiseq.metrics
done

cp ${SCRIPTDIR}/metrics_header.txt miseq.metrics

for i in $(ls -1 /btl/analysis/ChIPseq/mapq1/*-*/miseq/*/*_metrics.tsv)
do
    tail -n +2 $i | cut -f 1-22 >> miseq.metrics
done
