#!/bin/sh -x

# was RunAggregateFastq.sh from SS2 pipeline

FASTQ_DIR=$1
SEQUENCE_DATA_PATH=$2
BARCODE_1=$3
BARCODE_2=$4
SAMPLE_NAME=$5

#reverse complemented barcode
#RC_BARCODE_1=( $(echo $BARCODE_1 | rev | tr ATGC TACG))
RC_BARCODE_1=$3
#RC_BARCODE_2=( $(echo $BARCODE_2 | rev | tr ATGC TACG))
RC_BARCODE_2=$4

function aggregateFastqs {
	pair=$1
	echo "ls ${SEQUENCE_DATA_PATH}/*/*.${RC_BARCODE_1}_${RC_BARCODE_2}.unmapped.${pair}.fastq.gz"
	gzFileNames=( $( ls ${SEQUENCE_DATA_PATH}/*/*.${RC_BARCODE_1}_${RC_BARCODE_2}.unmapped.${pair}.fastq.gz))
	fastqStr=""

	#aggregate all of the fastq.gz
	i=0
	for FASTQ1 in ${gzFileNames[@]};do
		i=$((i+1))
		echo "Unzipping ${FASTQ1}..."
		gunzip -c ${FASTQ1} >${FASTQ_DIR}/${SAMPLE_NAME}.temp.${i}.fastq
		fastqStr+=" ${FASTQ_DIR}/${SAMPLE_NAME}.temp.${i}.fastq"
	done

	#if fastq's are in plain fastq format...
#	i=0
	if [ "$i" == 0 ]
	then
		fileNames=( $( ls ${SEQUENCE_DATA_PATH}/*/*.${RC_BARCODE_1}_${RC_BARCODE_2}.unmapped.${pair}.fastq))
		echo "ls ${SEQUENCE_DATA_PATH}/*/*.${RC_BARCODE_1}_${RC_BARCODE_2}.unmapped.${pair}.fastq"
		for FASTQ1 in ${fileNames[@]};do
			FASTQ1_SEARCH="${FASTQ1}.gz"
			if [[ ! ${gzFileNames[*]} =~ "${FASTQ1_SEARCH}" ]]; then
				echo "Appending ${FASTQ1}..."
				fastqStr+=" ${FASTQ1}"
			fi
		done
	fi
	
	#check for the length of fastqs
	if [[ -z $fastqStr ]]
	then
		echo "Fastq's are empty."
		exit 1		
	fi

	#run the cat commands that combines all of the fastqs
	echo "cat ${fastqStr} > ${FASTQ_DIR}/${SAMPLE_NAME}.${pair}.fastq"
	cat ${fastqStr} > ${FASTQ_DIR}/${SAMPLE_NAME}.${pair}.fastq

	#clean up
	echo "Cleaning up..."
	for ((j=1;j<=i;j++)); do
		echo "Removing temporary fastq file ${FASTQ_DIR}/${SAMPLE_NAME}.temp.${j}.fastq..."
		rm ${FASTQ_DIR}/${SAMPLE_NAME}.temp.${j}.fastq
	done

    gzip ${FASTQ_DIR}/${SAMPLE_NAME}.${pair}.fastq

}

if [ ! -d $FASTQ_DIR ]; then
	mkdir $FASTQ_DIR
fi;
aggregateFastqs 1
aggregateFastqs 2

#echo $RC_BARCODE_1
#echo $RC_BARCODE_2
