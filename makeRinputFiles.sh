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

orig=`pwd`

if [ -e all.metrics ]
  then
    echo "metrics file already exists, try again after you:"
    echo "rm ${orig}/all.metrics"
    exit
fi

head -n 1 /btl/analysis/ChIPseq/mapq1//SSF-12242/hiseq/v1/SSF-12242_hiseq_v1_metrics.tsv > all.metrics


for i in $(ls -1 /btl/analysis/ChIPseq/mapq1/*-*/[hm]iseq/*/*_metrics.tsv)
do
    tail -n +2 $i >> all.metrics
done

echo "experiments in all.metrics:"
cut -f 1 all.metrics | uniq

head -n 1 /btl/analysis/ChIPseq/mapq1//SSF-12242/hiseq/v1/SSF-12242_hiseq_v1_metrics.tsv > hiseq.metrics

for i in $(ls -1 /btl/analysis/ChIPseq/mapq1/*-*/hiseq/*/*_metrics.tsv)
do
    tail -n +2 $i >> hiseq.metrics
done

head -n 1 /btl/analysis/ChIPseq/mapq1//SSF-12242/hiseq/v1/SSF-12242_hiseq_v1_metrics.tsv > miseq.metrics

for i in $(ls -1 /btl/analysis/ChIPseq/mapq1/*-*/miseq/*/*_metrics.tsv)
do
    tail -n +2 $i >> miseq.metrics
done
