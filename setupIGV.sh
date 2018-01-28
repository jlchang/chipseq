######################
#
#  setupIGV.sh
#
#  set up directory and batch file for making IGV snapshots for SSF#
#
######################

#!/bin/bash

# set to print each command and exit script if any command fails
set -euo pipefail


SCRIPTDIR="/cil/shed/apps/internal/chipseq/dev/v0.06"

orig=$(pwd)
suffix=$(basename $orig)
type=$(basename $(dirname $orig))
ssf=$(basename $(dirname $(dirname $orig)))
expt=${ssf}_${type}_${suffix}

if [ -e housekeeping_${expt}.txt ]
  then
    echo "output file already exists, try again after you:"
    echo "rm housekeeping_${expt}.txt"
      if [ -d ${ssf}_${type}_IGV ]
        then
          echo "output dir also exists:"
          echo "rmdir ${ssf}_IGV"
      fi
    exit
fi

if [ -d ${ssf}_${type}_IGV ]
  then
    echo "output dir exists:"
    echo "rmdir ${ssf}_IGV"
  exit
fi

mkdir ${orig}/${ssf}_IGV

head -n 3 ${SCRIPTDIR}/housekeeping_template.txt | sed "s/SSF-XXXXX/$ssf/g" > housekeeping_${expt}.txt

for i in $(ls -1 ${orig}/*/*.mapq1.PE.nodup.bam); do echo "load $i"; done >> housekeeping_${expt}.txt

tail -n +5 ${SCRIPTDIR}/housekeeping_template.txt | sed "s/SSF-XXXXX/$expt/g" >> housekeeping_${expt}.txt

echo "To generate IGV snapshots (run on lager):"
echo "use Java-1.8"
#echo "/cil/shed/apps/external/IGV/IGV_2.4.6/igv.sh -b ${orig}/housekeeping_${expt}.txt"
echo "xvfb-run java -Xmx4000m -jar /cil/shed/apps/external/IGV/IGV_2.4.6/igv.jar -b ${orig}/housekeeping_${expt}.txt"
