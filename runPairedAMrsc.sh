######################
#
#  runPairedAlign.sh
#
#  for samples in input_data.tsv, run pairedAlignMarkD.sh for each sample
#
######################


#!/bin/bash

orig=`pwd`
source /broad/software/scripts/useuse
use UGER

SCRIPTDIR="/cil/shed/apps/internal/chipseq/prod"

set -e
echo "analysis directory is $orig"

if [ $# -lt 1 ]
  then
    echo "ERROR (missing analysis type)"
    exit
fi

if [ "$1" != "miseq" ] && [ "$1" != "hiseq" ]
  then
    echo "ERROR - analysis type must be miseq or hiseq, not $1"
    exit
fi

if [ "$1" = "miseq" ]
  then
    UGERPARAM1="-cwd -l h_vmem=8G -l h_rt=4:00:00"
fi

#SSF-12271 33M SE F04 aquas 8h 8.6G
#bedcov job required more than 12G on UGER
#12G sufficient for ~12M reads, SSF-12381 had 41M reads, failed on bedcov step
if [ "$1" = "hiseq" ]
  then
    UGERPARAM1="-cwd -l h_vmem=21G -l h_rt=18:00:00"
fi

while IFS=$'\t': read sample fastq1 fastq2
do
  echo "set up analysis dir for $i"
  cd $orig
  mkdir ${sample}_PE
  cd ${sample}_PE
  UGERPARAM2="-N S_${sample}"
    #syntax to use to avoid bad UGER host(s))
    #UGERPARAMS="-cwd -l h_vmem=10G -l h_rt=4:00:00 -l h=\'!(uger-c075|uger-c088)\' -N S_${sample}"
  echo "job to run in analysis dir: qsub $UGERPARAM1 $UGERPARAM2 $SCRIPTDIR/pairedAMrsc.sh ${sample} ${fastq1} ${fastq2}"
  qsub $UGERPARAM1 $UGERPARAM2 $SCRIPTDIR/pairedAMrsc.sh ${sample} ${fastq1} ${fastq2}
done < input_data.tsv
#done < test.in
