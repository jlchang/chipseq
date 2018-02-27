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

#check PIPE_LOC environment variable is set
#https://stackoverflow.com/questions/307503
: "${PIPE_LOC:?Need to set PIPE_LOC non-empty}"

SCRIPTDIR="/cil/shed/apps/internal/chipseq/$PIPE_LOC"

if [  ! -d "$SCRIPTDIR" ]
  then
    echo "Unable to find $SCRIPTDIR, please check the provided PIPE_LOC value"
    exit
fi

orig=$(pwd)
suffix=$(basename $orig)
type=$(basename $(dirname $orig))
ssf=$(basename $(dirname $(dirname $orig)))
expt=${ssf}_${type}_${suffix}
expt_path=${ssf}/${type}/${suffix}

if [ ! -f sampleByFRiP.txt ]
  then
    echo "missing sampleByFRiP.txt, try again after you create one"
    exit
fi

if [ -f ${expt}_IGV/housekeeping_${expt}.txt ]
  then
    echo "output file already exists, try again after you:"
    echo "rm ${expt}_IGV/housekeeping_${expt}.txt"
      if [ -d ${expt}_IGV ]
        then
          echo "output dir also exists:"
          echo "rmdir ${expt}_IGV"
      fi
    exit
fi

if [ -d ${expt}_IGV ]
  then
    echo "output dir exists:"
    echo "rmdir ${expt}_IGV"
  exit
fi

mkdir ${orig}/${expt}_IGV

#echo "making housekeeping file"

head -n 4 ${SCRIPTDIR}/housekeeping_template.txt | sed "s;EXPTPATH;$expt_path;g" | sed "s/SSF-XXXXX/$expt/g" > ${expt}_IGV/housekeeping_${expt}.txt

for i in $(cat ${orig}/sampleByFRiP.txt | cut -f 1)
do
  bam=$(ls ${orig}/${i}*/${i}*.mapq1.PE.nodup.bam)
  echo "load $bam"
done >> ${expt}_IGV/housekeeping_${expt}.txt

tail -n +5 ${SCRIPTDIR}/housekeeping_template.txt | sed "s/SSF-XXXXX/$expt/g" >> ${expt}_IGV/housekeeping_${expt}.txt

echo "To generate IGV snapshots (run on lager):"
echo "use Java-1.8"
#all the stuff in igv.sh
#echo "xvfb-run java -Xmx4000m -XX:+IgnoreUnrecognizedVMOptions --illegal-access=permit --add-modules=java.xml.bind -Dapple.laf.useScreenMenuBar=true -Djava.net.preferIPv4Stack=true -jar /cil/shed/apps/external/IGV/IGV_2.4.6/igv.jar -b ${orig}/${ssf}_IGV/housekeeping_${expt}.txt"
echo "xvfb-run java -Xmx4000m -jar /cil/shed/apps/external/IGV/IGV_2.4.6/igv.jar -b ${orig}/${expt}_IGV/housekeeping_${expt}.txt"
