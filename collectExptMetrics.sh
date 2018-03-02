######################
#
#  collectExptMetrics.sh
#
#  collect metrics from all samples in input_data.tsv into _metrics.tsv file 
#
######################

#!/bin/bash

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
    exit
fi


set -e
echo "collecting metrics from samples in $orig"


echo "Expt	Sample	Ctrl	Tot_Reads	MAPQ1_Reads	pctAnalyzed	mapq1PE_rip	mapq1PE_FRIP	R1_CHIMERAS	R1_ADAPTER	R2_CHIMERAS	R2_ADAPTER	pDUPLICATION	EstLibSize	RSC	NSC	QT	MapRaw_Reads	PropPr_Reads	PrSing_Reads	mmdc_Reads	pDup_Reads" >> ${result}

while IFS=$'\t': read sample fastq1 fastq2
do
#  echo "collect metrics for ${orig}/${sample}_PE/${sample}.Metrics"
  metrics=$(tail -n1 ${orig}/${sample}_PE/${sample}.Metrics)
  echo -ne "$expt\t" >> ${result}
  echo -ne "$sample\t" >> ${result}
  echo -ne "$(grep $sample control_info.txt | cut -f 2)\t" >> ${result}
  echo "$metrics" >> ${result}
done < input_data.tsv

