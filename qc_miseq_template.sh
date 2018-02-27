######################
#
#  qc_miseq_template.sh
#
#  boilerplate for JIRA QC text
#
######################


#!/usr/bin/env bash

display_usage() { 
    echo -e "\nUsage: $0 <metrics file prefix> \n" 
    } 
    

# if no arguments supplied, display usage 
    if [  $# -lt 1 ] 
    then 
        display_usage
        exit 1
    fi 


set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

echo "H3K27ac FRiP: ____% of batch with >5% H3K27ac FRiP 
mean H3K27ac FRiP: ____%

Controls: positive controls and negative control behaved as expected
(Criteria: >30% K562 H3K27ac FRiP; PBMC >10%; ~3% FRiP for no Ab ctrl, expect low read count; expect low/no reads for water)

Read Distribution:  no dropouts, no jackpot samples
(Dropout: sample total reads < 50,000 total reads for Miseq)
(Jackpot: sample total reads > 2 standard deviations above mean total reads)

Duplication: ____% of samples with >1% duplication
(Criteria: average below 1%; not more than 10% of batch with >1% duplication)

Adapter: passes QC criteria 
(Criteria: average below 5%; not more than 10% of batch with >5% adapter)

All sequencing cycles had mean quality >Q30

Attaching sample level report:
${1}_expt_report.pdf 

raw metrics file:
${1}.metrics.tsv

Cumulative expt-level report:
metrics_2018____.pdf"
