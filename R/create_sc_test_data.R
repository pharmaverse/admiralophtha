# Name: create_sc_test_data
#
#
# Label: Create test data for SC domain for study eye info
#
# Input: admiral_dm, admiral_sv

library(admiral)
library(admiral.test) # Contains example datasets from the CDISC pilot project
library(dplyr)

data("admiral_dm")
data("admiral_sv")

dm <- admiral_dm
sv <- admiral_sv

# Remove screen failures, they will not make it to drug infusion
dm1 <- dm %>%
  filter(ARMCD != "Scrnfail")


# use subjects in DM  and info from SV  Screening 1 visit
sc <- merge(dm1[, c("STUDYID", "USUBJID", "SUBJID", "RFSTDTC")],
  sv[sv$VISIT == "SCREENING 1", c("STUDYID", "USUBJID", "SVSTDTC", "VISIT")],
  by = c("STUDYID", "USUBJID")
)

# Create SC domain var
sc$DOMAIN <- "SC"
sc$SCCAT <- "STUDY EYE SELECTION"
sc$SCTESTCD <- "FOCID"
sc$SCTEST <- "Focus of Study-Specific Interest"
sc$EPOCH <- "SCREENING"
sc$SCDTC <- sc$SVSTDTC
sc$SCDY <- as.numeric(as.Date(sc$SCDTC) - as.Date(sc$RFSTDTC))
# Even SUBJID numbers will have study eye assigned to Left;  odd to Right
sc$SCORRES <- if_else(as.integer(sc$SUBJID) %% 2 == 0, "Left Eye", "Right Eye")
sc$SCSTRESC <- if_else(as.integer(sc$SUBJID) %% 2 == 0, "OS", "OD")


# SCSEQ;
sc <- sc %>%
  group_by(STUDYID, USUBJID) %>%
  dplyr::mutate(SCSEQ = row_number())


# keep relevant variables
sc <- subset(sc, select = c(
  "STUDYID", "DOMAIN", "USUBJID", "SCSEQ", "SCTESTCD", "SCTEST",
  "SCCAT", "SCORRES", "SCSTRESC", "EPOCH", "SCDTC", "SCDY"
))
sc <- sc %>%
  ungroup() %>%
  # sort data
  arrange(STUDYID, USUBJID, SCSEQ)



attr(sc$STUDYID, "label") <- "Study Identifier"
attr(sc$DOMAIN, "label") <- "Domain Abbreviation"
attr(sc$USUBJID, "label") <- "Unique Subject Identifier"
attr(sc$SCSEQ, "label") <- "Sequence Number"
attr(sc$SCTESTCD, "label") <- "Subject Characteristic Short Name"
attr(sc$SCTEST, "label") <- "Subject Characteristic"
attr(sc$SCCAT, "label") <- "Category for Subject Characteristic"
attr(sc$SCORRES, "label") <- "Result or Finding in Original Units"
attr(sc$SCSTRESC, "label") <- "Character Result/Finding in Std Format"
attr(sc$EPOCH, "label") <- "Epoch"
attr(sc$SCDTC, "label") <- "Date/Time of Collection"
attr(sc$SCDY, "label") <- "Study Day of Examination"


# ---- Save output ----
admiral_sc <- sc
save(admiral_sc, file = "./data/admiral_sc.rda", compress = "bzip2")
