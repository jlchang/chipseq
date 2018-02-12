######################
#
#  doneConfirm.sh
#
#  check all samples completed
#
######################

#!/bin/bash

orig=`pwd`



SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

fail=0
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
done < input_data.tsv

echo "fails = $fail"

