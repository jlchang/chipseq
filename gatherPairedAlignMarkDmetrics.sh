######################
#
#  gatherPairedAlignMarkDmetrics.sh
#
#  last step of alignMarkInput.sh to put gather metrics for the sample
#
######################

#!/bin/bash

set -e

#sample="F05-CD-H3K27ac"
sample=$1

# if no arguments supplied, complain 
if [  ! -e ${sample}.raw.cleaned.flagstat ] 
then 
    echo "please supply valid sample name"
    exit 1
fi 


#Total Reads
TR=$(head -1 ${sample}.raw.cleaned.flagstat | cut -d " " -f 1)

#Mapped raw reads
MRR=$(sed -n "5p" ${sample}.raw.cleaned.flagstat | grep mapped | awk '{ print $1}')

#Paired in Sequencing
PIS=$(sed -n "6p" ${sample}.raw.cleaned.flagstat | grep sequencing | awk '{ print $1}')

#ProperlyPaired
PP=$(sed -n "9p" ${sample}.raw.cleaned.flagstat | grep properly | awk '{ print $1}')

#Singletons
sing=$(sed -n "11p" ${sample}.raw.cleaned.flagstat | grep singletons | awk '{ print $1}')

#proper dups
pdup=$(sed -n "4p" ${sample}.mapq1.dupmark.flagstat | grep duplicates | awk '{ print $1}')

#with mate mapped to a different chr
mmdc=$(sed -n "12p" ${sample}.raw.cleaned.flagstat | grep different | awk '{ print $1}')



#MAPQ Reads
MR=$(head -1 ${sample}.mapq1.PE.nodup.flagstat | cut -d " " -f 1)


#CASM_R1_TOT
R1T=$(sed -n "8p" ${sample}.raw.cleaned.casm  | awk '{ print $2 }')
#CASM_R1_CHIMERAS
R1C=$(sed -n "8p" ${sample}.raw.cleaned.casm  | awk '{ print $23 }')
#CASM_R1_ADAPTER
R1A=$(sed -n "8p" ${sample}.raw.cleaned.casm  | awk '{ print $24 }')

#CASM_R2_TOT
R2T=$(sed -n "9p" ${sample}.raw.cleaned.casm  | awk '{ print $2 }')
#CASM_R2_CHIMERAS
R2C=$(sed -n "9p" ${sample}.raw.cleaned.casm  | awk '{ print $23 }')
#CASM_R2_ADAPTER
R2A=$(sed -n "9p" ${sample}.raw.cleaned.casm  | awk '{ print $24 }')

#ELC_READ_PAIRS_EXAMINED
elcpr=$(sed -n "8p" ${sample}.raw.cleaned.elc  | awk '{ print $3 }')
#PERCENT_DUPLICATION
dup=$(sed -n "8p" ${sample}.raw.cleaned.elc  | awk '{ print $9 }')
if [ -z "$dup" ]; then
  dup="0"
fi

#ESTIMATED_LIBRARY_SIZE
els=$(sed -n "8p" ${sample}.raw.cleaned.elc  | awk '{ print $10 }')

# -z check that $els has zero length
if [ -z "$els" ]; then
  els="N/A"
fi

#mapqPE_READS_in_H3K27ac_peaks
mperip=$(cat ${sample}.mapq1.PE.nodup.H3K27ac.rip)

if [ "$MR" == "0" ]; then
    mpefrip="N/A"
else 
    mpefrip=$(echo "scale=4; $mperip/$MR" | bc)
fi


#Phantom peak quality metrics, if it ran

if [ -s ${sample}.mapq1.PE2SE.nodup.15M.tagAlign.qc ]; then
  normSC=$(cut -f 9 ${sample}.mapq1.PE2SE.nodup.15M.tagAlign.qc)
else
  normSC="N/A"
fi

if [ -s ${sample}.mapq1.PE2SE.nodup.15M.tagAlign.qc ]; then
  relSC=$(cut -f 10 ${sample}.mapq1.PE2SE.nodup.15M.tagAlign.qc)
else
  relSC="N/A"
fi

if [ -s ${sample}.mapq1.PE2SE.nodup.15M.tagAlign.qc ]; then
  QT=$(cut -f 11 ${sample}.mapq1.PE2SE.nodup.15M.tagAlign.qc)
else
  QT="N/A"
fi

if [ "$TR" == "0" ]; then
    pctAn="N/A"
else 
    pctAn=$(echo "scale=4; $MR/$TR" | bc)
fi


echo -e "Tot_Reads\tMAPQ1_Reads\tpctAnalyzed\tmapq1PE_rip\tmapq1PE_FRIP\tR1_CHIMERAS\tR1_ADAPTER\tR2_CHIMERAS\tR2_ADAPTER\tpDUPLICATION\tEstLibSize\tRSC\tNSC\tQT\tMapRaw_Reads\tPropPr_Reads\tPrSing_Reads\tmmdc_Reads\tpDup_Reads"
echo -e "$TR\t$MR\t$pctAn\t$mperip\t$mpefrip\t$R1C\t$R1A\t$R2C\t$R2A\t$dup\t$els\t$relSC\t$normSC\t$QT\t$MRR\t$PP\t$sing\t$mmdc\t$pdup"

