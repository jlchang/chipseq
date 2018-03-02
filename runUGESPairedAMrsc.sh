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
reuse UGES


set -e
echo "analysis directory is $orig"

#check PIPE_LOC environment variable is set
#https://stackoverflow.com/questions/307503
: "${PIPE_LOC:?Need to set PIPE_LOC non-empty}"

SCRIPTDIR="/cil/shed/apps/internal/chipseq/$PIPE_LOC"

if [  ! -d "$SCRIPTDIR" ]
  then
    echo "Unable to find $SCRIPTDIR, please check the provided PIPE_LOC value"
    exit
fi

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
  qsub $UGESPARAMS -v PIPE_LOC $SCRIPTDIR/pairedAMrsc.sh ${sample} ${fastq1} ${fastq2}
done < input_data.tsv
#done < test.in
