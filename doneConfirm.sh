######################
#
#  doneConfirm.sh
#
#  check all samples completed
#
######################

#!/bin/bash

orig=`pwd`

#check PIPE_LOC environment variable is set
#https://stackoverflow.com/questions/307503
: "${PIPE_LOC:?Need to set PIPE_LOC non-empty}"

SCRIPTDIR="/cil/shed/apps/internal/chipseq/$PIPE_LOC"

if [  ! -d "$SCRIPTDIR" ]
  then
    echo "Unable to find $SCRIPTDIR, please check the provided PIPE_LOC value"
    exit
fi

fail=0
PPQT=0
all=$(wc -l input_data.tsv)
echo "Assessing $all samples:"
while IFS=$'\t': read sample fastq1 fastq2
do
  if [ ! -e ${sample}_PE/DONE ]

#if [ ! -e ${sample}_PE/${sample}.raw.cleaned.casm ]
  then
    fail=$((fail+1))
    echo "analysis for $sample did not complete"
    head -n 1 ${sample}_PE/${sample}.raw.cleaned.flagstat
#echo "$sample" >> fails.txt
  fi
  if [ ! -s ${sample}_PE/${sample}.mapq1.PE2SE.nodup.15M.tagAlign.qc ]
  then
    echo "PPQT failed on ${sample}"
    PPQT=$((PPQT+1))
  fi
done < input_data.tsv

echo "fails = $fail"
echo "PPQT N/A= $PPQT"
if [[ $fails -gt 0 ]]
then
  echo "Failed samples should be rerun or removed from input_data.tsv before metrics file is created"
  exit
fi

${SCRIPTDIR}/collectExptMetrics.sh
