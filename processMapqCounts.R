######################
#
#  processMapqCounts.R
#
#  bin read counts by mapq scores
#
######################


library(tidyverse)

report = list.files( path = "." , pattern = "*.count$")
outfile<-paste0(report,".bin")
{
if (length(report)==0) { stop("no report found")}
}
{
if (length(report) > 1) { stop("more than one report found")}
print("reporting on: ")
}
print(report)

df <- read.table(
  file = report,
  header=F,
  col.names=c("counts","mapq"),
  stringsAsFactors = FALSE
)

df <- df %>%
  mutate(
    cat = cut(mapq, breaks = c(0, 1, 6, 11, 15, 21, 25, 29, 30), right = FALSE, labels = c('mapq0', 'mapq5','mapq10', 'mapq15','mapq20', 'mapq25', 'mapq28','mapq29')
# dotkit R-3.3 tidyverse does not work with mutate + case_when
#leaving code here as a reminder of another option
#    ),
#      cat2 = case_when(
#      mapq == 0 ~ '0',
#      between(mapq, 1, 10) ~ '1-10',
#      between(mapq, 10, 20) ~ '10-20',
#      between(mapq, 21, 28) ~ '10-28',
#      TRUE ~ '29'
  )
)

df2 <- df %>%
  group_by(cat) %>%
  summarise(
    the_sum = sum(counts),
    fraction = the_sum/sum(df$count)
)

df3 <- df2 %>%
  mutate(
    cum = cumsum(the_sum)
)




write.table(df3, file=outfile, row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\t")
#write.table(df2, file=outfile, row.names = FALSE, quote = FALSE, sep = "\t")
