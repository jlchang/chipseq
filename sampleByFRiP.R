#!/usr/bin/env Rscript


report = list.files( path = "." , pattern = filename)

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
