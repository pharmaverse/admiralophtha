#' Program Name : qs.R

#' Description : create VFQ test data for ADMIRAL Ophtha

#' Input : admiralophtha_qs

#' Author : Ritika Aggarwal


library(admiral)
library(admiral.test) # contains test datasets from previous ADMIRAL project
library(dplyr)

# take qs test data from previous ADMIRAL project
admiral_qs <- admiral.test::admiral_qs

# create new QS data - keep standard variables from previous ADMIRAL project's QS
qs1 <- admiral_qs %>%
  # select standard variables
  select(STUDYID, DOMAIN, USUBJID, QSBLFL, VISITNUM, VISIT, VISITDY, QSDTC, QSDY) %>%
  # keep unique subjects and visits per subject
  group_by(USUBJID, VISITDY) %>%
  unique()

# read temporary qs data from a Novartis study
novqs <- readRDS("dev/novqs.RDS")

# merge standard QS with parameters and result variables from temp QS data
qs2 <- merge(qs1, novqs) %>%
  group_by(USUBJID) %>%
  # create QSSEQ based on VFQ QS parameters
  mutate(QSSEQ = row_number()) %>%
  arrange(USUBJID, QSSEQ) %>%
  select(
    STUDYID, DOMAIN, USUBJID, QSSEQ, QSTESTCD, QSTEST, QSCAT, QSSCAT,
    QSORRES, QSORRESU, QSSTRESC, QSSTRESN, QSSTRESU, QSBLFL, VISITNUM,
    VISIT, VISITDY, QSDTC, QSDY
  )

# output admiralophtha_qs.RDS
saveRDS(qs2, file = "inst/extdata/admiralophtha_qs.RDS")
