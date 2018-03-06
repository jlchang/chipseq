#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)
#test if there is at least one argument: if not, return an error
if (length(args)<1) {
  stop("Must supply metrics filename prefix).n", call.=FALSE)
}

metricsFile <- paste(args[1], "_metrics.tsv", sep="")

report = list.files( path = "." , pattern = metricsFile)

if (length(report)==0) { stop("no report found")}


if (length(report) > 1) { stop("more than one report found")}
print("reporting on: ")

print(report)

library(ggplot2)
library(hms)
library(tidyverse)

df <- read.table(
file = report,
sep="\t",
header=T,
stringsAsFactors = TRUE
)

#create sampleByFRiP.txt
df %>% arrange(mapq1PE_FRIP) %>% select(Sample, mapq1PE_FRIP) %>% write.table(file = 'sampleByFRiP.txt', row.names = FALSE, sep = "\t", quote = FALSE, col.names = FALSE)
