######################
#
#  operateExptReport_miseq.sh
#
#  Simplify running expt_report.Rmd for miseq runs
#
######################


#!/usr/bin/env bash

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

#check PIPE_LOC environment variable is set
#https://stackoverflow.com/questions/307503
: "${PIPE_LOC:?Need to set PIPE_LOC non-empty}"

SCRIPTDIR="/cil/shed/apps/internal/chipseq/$PIPE_LOC"

if [  ! -d "$SCRIPTDIR" ]
  then
    echo "Unable to find $SCRIPTDIR, please check the provided PIPE_LOC value"
    exit
fi

version=$(basename "$1")
type=$(basename $(dirname "$1"))
ssf=$(basename $(dirname $(dirname "$1")))
m_root=$(dirname $(dirname $(dirname "$1")))

m_dir="${m_root}/${ssf}/${type}/${version}"
m_file="${m_dir}/${ssf}_${type}_${version}_metrics.tsv"
m_out="${m_dir}/${ssf}_${type}_${version}_expt_report.pdf"

if [  $# -gt 1 ] 
then 
    m_dir=$(dirname $2)
    m_out=$(basename $2)
    #for testing with non-production input at output location
    #comment out for production to use to redirect output
    #m_file="${m_dir}/${ssf}_${type}_${version}_metrics.tsv"
fi 

Rscript -e "library(rmarkdown); render(\"${SCRIPTDIR}/expt_report.Rmd\", output_format = \"pdf_document\",  knit_root_dir=\"$m_dir\", output_dir=\"$m_dir\", intermediates_dir=\"$m_dir\", output_file = \"$m_out\", params = list(input=\"$m_file\"))"
