######################
#
#  pairedAMrsc.sh
#
#  generate basic metrics on ChIPseq paired reads
#
######################


#!/usr/bin/env bash


eval export DK_ROOT="/broad/software/dotkit"; . /broad/software/dotkit/ksh/.dk_init
reuse -q .bwa-0.7.15
reuse -q .samtools-1.5
reuse -q .java-jdk-1.8.0_121-x86-64
reuse -q .bedtools-2.26.0
reuse -q .r-3.3.0

# set to print each command and exit script if any command fails
set -euxo pipefail

# set exit script if any command fails (-e and -o pipefail) or unset variable found (-u)
#set -euo pipefail

#check PIPE_LOC environment variable is set
#https://stackoverflow.com/questions/307503
: "${PIPE_LOC:?Need to set PIPE_LOC non-empty}"

SCRIPTDIR="/cil/shed/apps/internal/chipseq/$PIPE_LOC"

if [  ! -d "$SCRIPTDIR" ]
  then
    echo "Unable to find $SCRIPTDIR, please check the provided PIPE_LOC value"
    exit
fi

echo "execution host: $HOSTNAME" >> run_info.txt
echo "PIPE_LOC: $PIPE_LOC" >> run_info.txt

# =============================
# Inputs:
# sampleName
# fastq1
# fastq2
# BWA genome index
# =============================

#sampleName
OFPREFIX="$1"

# fastq1
FASTQ_FILE_1="$2"
# fastq2
FASTQ_FILE_2="$3"

# BWA genome index
BWA_INDEX_NAME="/cil/shed/apps/external/AQUAS/genome_data/hg19/bwa_index/male.hg19.fa"
# threads
NTHREADS="1"


SAI_FILE_1="${OFPREFIX}_1.sai" 
SAI_FILE_2="${OFPREFIX}_2.sai" 
RAW_SAM_FILE="${OFPREFIX}.raw.sam.gz"
RAW_BAM_PREFIX="${OFPREFIX}.raw"
RAW_BAM_FILE="${RAW_BAM_PREFIX}.bam"
RAW_BAM_FILE_MAPSTATS="${RAW_BAM_PREFIX}.flagstat"
RAW_CLEAN_PREFIX="${OFPREFIX}.raw.cleaned"
RAW_CLEAN_FILE="${RAW_CLEAN_PREFIX}.bam"
RAW_CLEAN_FILE_MAPSTATS="${RAW_CLEAN_PREFIX}.flagstat"

#estimate library complexity fails to run unless all unmapped reads are mapq=0
CLEANSAM="/seq/software/picard-public/2.14.0/picard.jar CleanSam"

bwa aln -q 5 -l 32 -k 2 -t ${NTHREADS} ${BWA_INDEX_NAME} ${FASTQ_FILE_1} > ${SAI_FILE_1}
bwa aln -q 5 -l 32 -k 2 -t ${NTHREADS} ${BWA_INDEX_NAME} ${FASTQ_FILE_2} > ${SAI_FILE_2}
bwa sampe ${BWA_INDEX_NAME} ${SAI_FILE_1} ${SAI_FILE_2} ${FASTQ_FILE_1} ${FASTQ_FILE_2} | gzip -nc > ${RAW_SAM_FILE}
#clean up intermediate files
rm ${SAI_FILE_1} ${SAI_FILE_2}



samtools view -bhS ${RAW_SAM_FILE} | samtools sort - -T 'sorted_temp' -o ${RAW_BAM_FILE}
java -Xmx4G -jar ${CLEANSAM} I=${RAW_BAM_FILE} O=${RAW_CLEAN_FILE}

#clean up intermediate files
rm ${RAW_SAM_FILE}
#samtools flagstat ${RAW_BAM_FILE} > ${RAW_BAM_FILE_MAPSTATS}
samtools flagstat ${RAW_CLEAN_FILE} > ${RAW_CLEAN_FILE_MAPSTATS}
rm ${RAW_BAM_FILE}

# =============
# DEV
# generate sam file for mapq <30
# =============

samtools view -U ${RAW_CLEAN_FILE}.below_Mapq30.sam -q 30 ${RAW_CLEAN_FILE} > /dev/null
cat ${RAW_CLEAN_FILE}.below_Mapq30.sam | cut -f 5 | sort | uniq -c > ${RAW_CLEAN_FILE}.below_Mapq30.count

rm ${RAW_CLEAN_FILE}.below_Mapq30.sam

# =============
#  create MAPQ-filtered bam
# =============

TMP_FILT_BAM_PREFIX="tmp.${OFPREFIX}.filt.srt.nmsrt" 
TMP_FILT_BAM_FILE="${TMP_FILT_BAM_PREFIX}.bam" 
RAW_MAPQ_PREFIX="${OFPREFIX}.mapq1"
RAW_MAPQ_FILE="${RAW_MAPQ_PREFIX}.bam"
RAW_MAPQ_FILE_MAPSTATS="${RAW_MAPQ_PREFIX}.flagstat"

PAIRED_MAPQ_THRESH=1

samtools view -bh -f 2 -q ${PAIRED_MAPQ_THRESH} ${RAW_CLEAN_FILE} | samtools sort -n - -T 'sorted_temp' -o ${TMP_FILT_BAM_FILE} 

#samtools flagstat ${RAW_MAPQ_FILE} > ${RAW_MAPQ_FILE_MAPSTATS}

# Remove orphan reads (pair was removed)
# and read pairs mapping to different chromosomes 
# Obtain position sorted BAM
samtools fixmate ${TMP_FILT_BAM_FILE} ${OFPREFIX}.fixmate.tmp
samtools view -bh -F 1804 -f 2 ${OFPREFIX}.fixmate.tmp | samtools sort - -T 'sorted_temp' -o ${RAW_MAPQ_FILE} 

#clean up intermediate files
rm ${OFPREFIX}.fixmate.tmp
rm ${TMP_FILT_BAM_FILE}

# =============
# Mark duplicates
# =============
#MARKDUP="/seq/software/picard-public/current/picard.jar MarkDuplicates"
MARKDUP="/seq/software/picard-public/2.14.0/picard.jar MarkDuplicates"

#del#DUPMARK_RAW_BAM_PREFIX="${RAW_CLEAN_PREFIX}.dupmark"
#del#DUPMARK_RAW_BAM_FILE="${DUPMARK_RAW_BAM_PREFIX}.bam"
#del#DUPMARK_RAW_BAM_QC="${DUPMARK_RAW_BAM_PREFIX}.markdupMetrics"
#del#java -Xmx4G -jar ${MARKDUP} INPUT=${RAW_CLEAN_FILE} OUTPUT=${DUPMARK_RAW_BAM_FILE} METRICS_FILE=${DUPMARK_RAW_BAM_QC} VALIDATION_STRINGENCY=LENIENT ASSUME_SORTED=true REMOVE_DUPLICATES=false

#samtools flagstat ${DUPMARK_RAW_BAM_FILE} >${DUPMARK_RAW_BAM_PREFIX}.flagstat

DUPMARK_MAPQ_BAM_PREFIX="${RAW_MAPQ_PREFIX}.dupmark"
DUPMARK_MAPQ_BAM_FILE="${DUPMARK_MAPQ_BAM_PREFIX}.bam"
DUPMARK_MAPQ_BAM_QC="${DUPMARK_MAPQ_BAM_PREFIX}.markdupMetrics"
java -Xmx4G -jar ${MARKDUP} INPUT=${RAW_MAPQ_FILE} OUTPUT=${DUPMARK_MAPQ_BAM_FILE} METRICS_FILE=${DUPMARK_MAPQ_BAM_QC} VALIDATION_STRINGENCY=LENIENT ASSUME_SORTED=true REMOVE_DUPLICATES=false

samtools flagstat ${DUPMARK_MAPQ_BAM_FILE} >${DUPMARK_MAPQ_BAM_PREFIX}.flagstat

rm ${RAW_MAPQ_FILE}

# ============================ 
# Remove duplicates
# Index position sorted BAMs
##### (not necessary?) Create final name sorted BAM
# ============================ 


#del#PAIRED_BAM_PREFIX="${OFPREFIX}.PE.nodup" 
#del#PAIRED_BAM_FILE="${PAIRED_BAM_PREFIX}.bam" # To be stored 
#del#PAIRED_BAM_INDEX_FILE="${PAIRED_BAM_PREFIX}.bai" 
#del#PAIRED_BAM_FILE_MAPSTATS="${PAIRED_BAM_PREFIX}.flagstat" # QC file 
#del#samtools view -F 1804 -f 2 -bh ${DUPMARK_RAW_BAM_FILE} > ${PAIRED_BAM_FILE}


PAIRED_MAPQ_PREFIX="${RAW_MAPQ_PREFIX}.PE.nodup" 
PAIRED_MAPQ_FILE="${PAIRED_MAPQ_PREFIX}.bam" # To be stored 
PAIRED_MAPQ_INDEX_FILE="${PAIRED_MAPQ_PREFIX}.bai" 
PAIRED_MAPQ_FILE_MAPSTATS="${PAIRED_MAPQ_PREFIX}.flagstat" # QC file 
samtools view -F 1804 -f 2 -bh ${DUPMARK_MAPQ_BAM_FILE} > ${PAIRED_MAPQ_FILE}


# Index Final BAM files
#del#samtools index ${PAIRED_BAM_FILE} ${PAIRED_BAM_INDEX_FILE}
samtools index ${PAIRED_MAPQ_FILE} ${PAIRED_MAPQ_INDEX_FILE}


# Final BAM flagstats
#del#samtools flagstat ${PAIRED_BAM_FILE} > ${PAIRED_BAM_FILE_MAPSTATS}
samtools flagstat ${PAIRED_MAPQ_FILE} > ${PAIRED_MAPQ_FILE_MAPSTATS}


# =============
# EstimateLibraryComplexity
# CollectAlignmentSummaryMetrics
# =============

ELC="/seq/software/picard-public/2.14.0/picard.jar EstimateLibraryComplexity"
CASM="/seq/software/picard-public/2.14.0/picard.jar CollectAlignmentSummaryMetrics"

# elc fails on raw bam, needs cleaned bam
#del#java -Xmx4G -jar ${ELC} I=${RAW_BAM_FILE} O=${RAW_BAM_PREFIX}.elc
java -Xmx4G -jar ${ELC} I=${RAW_CLEAN_FILE} O=${RAW_CLEAN_PREFIX}.elc
#del#java -Xmx4G -jar ${ELC} I=${DUPMARK_RAW_BAM_FILE} O=${DUPMARK_RAW_BAM_PREFIX}.elc
#java -Xmx4G -jar ${ELC} I=${DUPMARK_MAPQ_BAM_FILE} O=${DUPMARK_MAPQ_BAM_PREFIX}.elc


#del#java -Xmx4G -jar ${CASM} R=${BWA_INDEX_NAME} I=${PAIRED_BAM_FILE} O=${PAIRED_BAM_PREFIX}.casm
#del#java -Xmx4G -jar ${CASM} R=${BWA_INDEX_NAME} I=${PAIRED_MAPQ_FILE} O=${PAIRED_MAPQ_PREFIX}.casm

java -Xmx4G -jar ${CASM} R=${BWA_INDEX_NAME} I=${RAW_CLEAN_FILE} O=${RAW_CLEAN_PREFIX}.casm

#rm ${DUPMARK_RAW_BAM_FILE}
rm ${DUPMARK_MAPQ_BAM_FILE}



# =============
# count FRIP reads (reference set: ensembl_jan2011)
# =============

# H3k27ac = K562H3k27ac (need to refactor to match handling of other peaks)

peak_dir="/btl/projects/ChIPseq/ENCODE/data/IGV_tracks/takeda_hg19_refs/ensembl_jan2011"
chr_file="/btl/projects/ChIPseq/ENCODE/data/IGV_tracks/chromosomes.txt"


cat /btl/projects/ChIPseq/ENCODE/data/IGV_tracks/wgEncodeBroadHistoneK562H3k27acStdAln.sorted.bed | bedtools coverage -sorted -g $chr_file -a - -b ${PAIRED_MAPQ_FILE} > ${PAIRED_MAPQ_PREFIX}.H3K27ac.bedcov
awk '{ sum += $11 } END { print sum ; }' ${PAIRED_MAPQ_PREFIX}.H3K27ac.bedcov > ${PAIRED_MAPQ_PREFIX}.H3K27ac.rip

for i in Gm12878H3k27ac Gm12878H3k4me2 K562H3k4me2 K562H3k4me3
do
    peak_path="${peak_dir}/wgEncodeBroadHistone${i}StdAln.sorted.bed"
    cat $peak_path | bedtools coverage -sorted -g $chr_file -a - -b ${PAIRED_MAPQ_FILE} > ${PAIRED_MAPQ_PREFIX}.${i}.bedcov
    awk '{ sum += $11 } END { print sum ; }' ${PAIRED_MAPQ_PREFIX}.${i}.bedcov > ${PAIRED_MAPQ_PREFIX}.${i}.rip
done

# =============
# create TagAlign files
# =============

PAIRED_MAPQ_NMSRT_FILE="${PAIRED_MAPQ_PREFIX}.nmsrt.bam"
TAG_ALIGN_PREFIX="${RAW_MAPQ_PREFIX}.PE2SE.nodup"
BEDPE_FILE="${TAG_ALIGN_PREFIX}.bedpe.gz"
FULL_TAG_ALIGN_FILE="${TAG_ALIGN_PREFIX}.tagAlign.gz"
SUBSAMPLE_TAG_ALIGN_FILE="${TAG_ALIGN_PREFIX}.15M.tagAlign.gz"


samtools sort -n ${PAIRED_MAPQ_FILE} -o ${PAIRED_MAPQ_NMSRT_FILE}

bedtools bamtobed -bedpe -mate1 -i ${PAIRED_MAPQ_NMSRT_FILE} | gzip -nc > ${BEDPE_FILE}

zcat ${BEDPE_FILE} | awk 'BEGIN{OFS="\t"}{printf "%s\t%s\t%s\tN\t1000\t%s\n%s\t%s\t%s\tN\t1000\t%s\n",$1,$2,$3,$9,$4,$5,$6,$10}' | gzip -nc > ${FULL_TAG_ALIGN_FILE}


  zcat ${BEDPE_FILE} | grep -v "chrM" | shuf -n 15000000 --random-source=/cil/shed/apps/external/AQUAS/genome_data/hg19/bwa_index/male.hg19.fa  | awk 'BEGIN{OFS="\t"}{print $1,$2,$3,"N","1000",$9}' | gzip -nc > ${SUBSAMPLE_TAG_ALIGN_FILE}

rm ${PAIRED_MAPQ_NMSRT_FILE}

# =============
# Phantom Peak Quality Tools
# =============

SUBSAMPLE_QC="${TAG_ALIGN_PREFIX}.15M.tagAlign.qc"

#PPQT fails if insufficient reads- want metrics, so ignore failures
set +e
Rscript $SCRIPTDIR/run_spp.R -c=${SUBSAMPLE_TAG_ALIGN_FILE} -savp -out=${SUBSAMPLE_QC}

sed -r 's/,[^\t]+//g' ${SUBSAMPLE_QC} > subsample.tmp
mv subsample.tmp ${SUBSAMPLE_QC}

set -e

# =============
# gather metrics
# =============

Rscript $SCRIPTDIR/processMapqCounts.R


#metrics script rewritten to supply "N/A" if no PPTQ output
$SCRIPTDIR/gatherPairedAlignMarkDmetrics.sh $1 > $1.Metrics


# =============
# declare DONE
# =============

touch DONE
