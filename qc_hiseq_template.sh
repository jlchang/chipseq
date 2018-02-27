######################
#
#  qc_hiseq_template.sh
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

echo "

XXX samples did not reach 10 million analyzed reads due to high duplication 
all non-dropout samples had >10 million total reads

H3K27ac FRiP scores 
see attachment metrics_2018____.pdf

____ of the ____ samples had >5% duplication
____ samples had >10% duplication
see attachment ${1}_expt_report.pdf

housekeeping IGV plots show convincing peaks for samples with >4% H3K27ac FRiP 
some samples with >3% H3K27ac FRiP may also have peaks 
see attachment ${1}_housekeeping_IGV.pdf

All sequencing cycles had mean quality >Q30
raw metrics attachment: ${1}.metrics.tsv"
