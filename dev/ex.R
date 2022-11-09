# ------------ admiralophtha ex test data ------------ #

library(dplyr)
library(tidyselect)
library(admiral)
library(admiral.test)

# Make admiralophtha_ex dataset
admiralophtha_ex <- admiral_dm %>%
  # Start by merging on admiralophtha_dm to use the SUBJID variable
  select(USUBJID, SUBJID) %>%
  right_join(admiral_ex, by = c("USUBJID")) %>%
  # Create EXLOC & EXLAT, change EXROUTE & EXDOSFRM to something eye-related
  mutate(
    EXLOC = "EYE",
    EXDOSFRM = "INJECTION",
    EXDOSFRQ = "ONCE",
    EXLAT = ifelse(as.integer(SUBJID) %% 2 == 0, "LEFT", "RIGHT"),
    EXROUTE = "INTRAVITREAL"
  ) %>%
  # Drop SUBJID and reorder variables
  select(
    "USUBJID", "STUDYID", "DOMAIN", "EXSEQ", "EXTRT", "EXDOSE",
    "EXDOSU", "EXDOSFRM", "EXDOSFRQ", "EXROUTE", "EXLOC",
    "EXLAT", "VISITNUM", "VISIT", "VISITDY", "EXSTDTC",
    "EXENDTC", "EXSTDY", "EXENDY"
  )

# Label new variables
attr(admiralophtha_ex$EXLOC, "label") <- "Location of Dose Administration"
attr(admiralophtha_ex$EXLAT, "label") <- "Laterality"
attr(admiralophtha_ex$EXROUTE, "label") <- "Route of Administration"
attr(admiralophtha_ex$EXDOSFRM, "label") <- "Dose Form"
attr(admiralophtha_ex$EXDOSFRQ, "label") <- "Dose Frequency per Interval"

# Save Dataset
saveRDS(admiralophtha_ex, "inst/extdata/admiralophtha_ex.RDS")
