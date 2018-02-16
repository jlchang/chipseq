######################
#
#  doneConfirm.sh
#
#  check all samples completed
#
######################

#!/bin/bash

orig=`pwd`

SCRIPTDIR="/cil/shed/apps/internal/chipseq/dev/v0.06"

fail=0
PPQT=0
all=$(wc -l input_data.tsv)
echo "Assessing $all samples:"
while IFS=$'\t': read sample fastq1 fastq2
do
  if [ ! -e ${sample}_PE/DONE_DEV ]
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
