#!/usr/bin/env Rscript


args = commandArgs(trailingOnly=TRUE)
#test if there is at least one argument: if not, return an error
if (length(args)<2) {
  stop("Must supply experiment type and metrics filename prefix).n", call.=FALSE)
}

filename <- paste(args[2], ".metrics_p5.1", sep="")

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

outfile <- paste(args[2], "reads.pdf", sep="_")

if (args[1]=="miseq") {
    pdf(outfile)
    ggplot(data=df, aes(x = reorder(Sample, Tot_Reads), y=Tot_Reads)) + geom_bar(stat="identity", fill = "grey", colour = "black") + 
    geom_bar(data = df, aes(x = reorder(Sample, MAPQ1_Reads), y = MAPQ1_Reads), stat = "identity", fill = "grey", colour = "blue") +
    theme(axis.text.x = element_text(size=5, angle = 90, hjust = 1)) 
    dev.off()
} else { if (args[1]=="hiseq") {
    pdf(outfile)
    ggplot(data=df, aes(x = reorder(Sample, Tot_Reads), y=Tot_Reads)) + geom_bar(stat="identity", fill = "grey", colour = "black") + 
    geom_bar(data = df, aes(x = reorder(Sample, MAPQ1_Reads), y = MAPQ1_Reads), stat = "identity", fill = "grey", colour = "blue") +
    theme(axis.text.x = element_text(size=5, angle = 90, hjust = 1)) + 
    geom_hline(yintercept=10000000, colour ="red") 
    dev.off()
    
    #create sampleByFRiP.txt
    df %>% arrange(mapq1PE_FRIP) %>% select(Sample, mapq1PE_FRIP) %>% write.table(file = 'sampleByFRiP.txt', row.names = FALSE, sep = "\t", quote = FALSE, col.names = FALSE)
    }
}


