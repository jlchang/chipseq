######################
#
#  runUGESPairedAlign.sh
#
#  for samples in input_data.tsv, run pairedAlignMarkD.sh for each sample
#
######################


#!/bin/bash

orig=`pwd`
source /broad/software/scripts/useuse
use UGES

SCRIPTDIR="/cil/shed/sandboxes/jlchang/notebook/scripts/ChIPseq/paired/v0.05"


set -e
echo "analysis directory is $orig"

while IFS=$'\t': read sample fastq1 fastq2
do
  echo "set up analysis dir for $i"
  cd $orig
  mkdir ${sample}_PE
  cd ${sample}_PE
  UGESPARAMS="-cwd -q btl -N S_${sample}"
    #syntax to use to avoid bad UGER host(s))
    #UGERPARAMS="-cwd -l h_vmem=10G -l h_rt=4:00:00 -l h=\'!(uger-c075|uger-c088)\' -N S_${sample}"
  echo "job to run in analysis dir: qsub $UGESPARAMS $SCRIPTDIR/pairedAMrsc.sh ${sample} ${fastq1} ${fastq2}"
  qsub $UGESPARAMS $SCRIPTDIR/pairedAMrsc.sh ${sample} ${fastq1} ${fastq2}
done < input_data.tsv
#done < test.in
