#!/usr/bin/env Rscript


args = commandArgs(trailingOnly=TRUE)
#test if there is at least one argument: if not, return an error
if (length(args)<1) {
  stop("Must supply metrics filename prefix).n", call.=FALSE)
}

metricsFile <- paste(args[1], "unalignedBam_mean_qual_by_cycle.txt", sep="")

cat("\n")
cat("reporting on: \n")

cat(metricsFile)
cat("\n")
cat("\n")

suppressMessages(library(tidyverse))

startFinder <- scan(metricsFile, what="character", sep="\n", quiet=TRUE, blank.lines.skip=FALSE)

firstBlankLine=0

for (i in 1:length(startFinder))
{
        if (startFinder[i] == "") {
                if (firstBlankLine==0) {
                        firstBlankLine=i+1
                } else {
                        secondBlankLine=i+1
                        break
                }
        }
}

metrics <- read.table(metricsFile, header=T, sep="\t", skip=firstBlankLine)

cat("cycles in metrics file:\n")
cat(nrow(metrics))
cat("\n")
cat("\n")

cat("cycles with Mean_Quality <30:\n")
print(metrics %>% filter(MEAN_QUALITY <30), row.names = FALSE)

