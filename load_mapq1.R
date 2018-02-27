#!/usr/bin/env Rscript


# args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
# if (length(args)==0) {
#   stop("At least one argument must be supplied (input file).n", call.=FALSE)
# } else if (length(args)==1) {
#   # default output file prefix
#   args[2] = "foo"
# }

library(ggplot2)
library(hms)
library(tidyverse)

df <- read.table(
file = args[1],
sep="\t",
header=T,
stringsAsFactors = TRUE
)

#To add dates, need to separate Analysis into it's SSF and its analysis_label
df2 <- df %>% mutate(Expt2 = Expt) %>% separate(Expt2, into = c( "SSF" , "seq_type", "label" ), sep = "_" )

expt_date <- read.table(
file = "/btl/analysis/ChIPseq/mapq1/analysis/ssf_date.tsv",
sep="\t",
header=T,
stringsAsFactors = TRUE
)

expt_date2 <- expt_date %>% mutate(Date = parse_date(Date, "%m/%d/%y"))

df3 <- left_join(df2, expt_date2, by = "SSF")

df4 <- df3 %>% mutate(fcat=cut(mapq1PE_FRIP, breaks=c(-Inf, 0.03, 0.05, 0.1, Inf), labels=c("<3%","3%<X<5%", "5%<X<10%",">10%")))

samples <- df4 %>% filter(Ctrl=="no") %>% mutate(pctA = MAPQ1_Reads/Tot_Reads)
