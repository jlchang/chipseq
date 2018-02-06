######################
#
#  setupFripSortedIGV.sh
#
#  set up directory and batch file for making IGV snapshots for SSF#
# according to sample order in sampleByFRiP.txt
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

if [ ! -f sampleByFRiP.txt ]
  then
    echo "missing sampleByFRiP.txt, try again after you create one"
    exit
fi

if [ -f housekeeping_${expt}.txt ]
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

head -n 4 ${SCRIPTDIR}/housekeeping_template.txt | sed "s/SSF-XXXXX/$ssf/g" > ${ssf}_IGV/housekeeping_${expt}.txt

for i in $(cat ${orig}/sampleByFRiP.txt | cut -f 1)
do
  bam=$(ls ${orig}/${i}*/${i}*.mapq1.PE.nodup.bam)
  echo "load $bam"
done >> ${ssf}_IGV/housekeeping_${expt}.txt

tail -n +5 ${SCRIPTDIR}/housekeeping_template.txt | sed "s/SSF-XXXXX/$expt/g" >> ${ssf}_IGV/housekeeping_${expt}.txt

echo "To generate IGV snapshots (run on lager):"
echo "use Java-1.8"
#all the stuff in igv.sh
#echo "xvfb-run java -Xmx4000m -XX:+IgnoreUnrecognizedVMOptions --illegal-access=permit --add-modules=java.xml.bind -Dapple.laf.useScreenMenuBar=true -Djava.net.preferIPv4Stack=true -jar /cil/shed/apps/external/IGV/IGV_2.4.6/igv.jar -b ${orig}/${ssf}_IGV/housekeeping_${expt}.txt"
echo "xvfb-run java -Xmx4000m -jar /cil/shed/apps/external/IGV/IGV_2.4.6/igv.jar -b ${orig}/${ssf}_IGV/housekeeping_${expt}.txt"
