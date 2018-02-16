######################
#
#  operateMetricsReport.sh
#
#  Simplify running metrics.Rmd
#
######################


#!/usr/bin/env bash

SCRIPTDIR="/cil/shed/apps/internal/chipseq/dev/v0.06"

display_usage() { 
    echo -e "\nUsage: $0 \$(pwd) (optional: output filename with path)\n" 
    } 
    

# if no arguments supplied, display usage 
    if [  $# -lt 1 ] 
    then 
        display_usage
        exit 1
    fi 
    


source /broad/software/scripts/useuse
use R-3.3
use .pandoc-1.12.4.2

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

a_date=$(date +%Y%m%d)
a_dir=${1}/${a_date}
if [ -d "$a_dir" ]; then
  echo "analysis directory already exists! exiting..."
else
  mkdir $a_dir
fi
cd $a_dir
${SCRIPTDIR}/makeRinputFiles.sh
a_file="${a_dir}/all.metrics"
a_out="${a_dir}/metrics_${a_date}.pdf"

if [  $# -gt 1 ] 
then 
    a_dir=$(dirname $2)
    a_out=$(basename $2)
    #for testing, use test input at output location
    #comment out for production to use to redirect output
    a_file="${a_dir}/all.metrics"
fi 

Rscript -e "library(rmarkdown);  render(\"${SCRIPTDIR}/metrics.Rmd\", output_format = \"pdf_document\", output_dir=\"$a_dir\", intermediates_dir=\"$a_dir\", output_file = \"$a_out\", params = list(input=\"$a_file\"))"

