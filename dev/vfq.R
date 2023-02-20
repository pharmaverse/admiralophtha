#' Program Name : vfq.R

#' Description : create VFQ test data for ADMIRAL Ophtha

#' Input : admiralophtha_qs

#' Author : Ritika Aggarwal


library(admiral)
library(admiral.test) # contains test datasets from previous ADMIRAL project
library(dplyr)

# take qs test data from previous ADMIRAL project ====
admiral_qs <- admiral.test::admiral_qs

# create new QS data - keep standard variables from previous ADMIRAL project's QS ====
qs1 <- admiral_qs %>%
  # select standard variables
  select(STUDYID, DOMAIN, USUBJID, QSBLFL, VISITNUM, VISIT, VISITDY, QSDTC, QSDY) %>%
  # keep unique subjects and visits per subject
  group_by(USUBJID, VISITDY) %>%
  unique()

# create dummy parameters and results ====
dummy_param <- c(
  "Your Overall Health Is",
  "Eyesight Using Both Eyes Is",
  "How Often You Worry About Eyesight",
  "How Much Pain in and Around Eyes",
  "Difficulty Reading Newspapers",
  "Difficulty Doing Work/Hobbies",
  "Difficulty Finding on Crowded Shelf",
  "Difficulty Reading Street Signs",
  "Difficulty Going Down Step at Night",
  "Difficulty Noticing Objects to Side",
  "Difficulty Seeing How People React",
  "Difficulty Picking Out Own Clothes",
  "Difficulty Visiting With People",
  "Difficulty Going Out to See Movies",
  "Are You Currently Driving",
  "Never Driven or Given Up Driving",
  "Main Reason You Gave Up Driving",
  "Difficulty Driving During Daytime",
  "Difficulty Driving at Night",
  "Driving in Difficult Conditions",
  "Eye Pain Keep From Doing What Like",
  "I Stay Home Most of the Time",
  "I Feel Frustrated a Lot of the Time",
  "I Need a Lot of Help From Others",
  "Worry I'll Do Embarrassing Things",
  "Difficulty Reading Small Print",
  "Difficulty Figure Out Bill Accuracy",
  "Difficulty Shaving or Styling Hair",
  "Difficulty Recognizing People",
  "Difficulty Taking Part in Sports",
  "Difficulty Seeing Programs on TV"
)
dummy_resc <- c(
  "GOOD",
  "FAIR",
  "RARELY",
  "NO",
  "SOME DIFFICULTY",
  "NO DIFFICULTY",
  "NO DIFFICULTY",
  "SOME DIFFICULTY",
  "SOME DIFFICULTY",
  "SOME DIFFICULTY",
  "SOME DIFFICULTY",
  "NO DIFFICULTY",
  "NO DIFFICULTY",
  "SOME DIFFICULTY",
  "YES",
  "NO",
  "NO",
  "NO",
  "YES",
  "YES",
  "YES",
  "NO",
  "SOMETIMES",
  "SOMETIMES",
  "YES",
  "VERY DIFFICULT",
  "SOME DIFFICULTY",
  "NO DIFFICULTY",
  "NO DIFFICULTY",
  "SOME DIFFICULTY",
  "NO DIFFICULTY"
)

dummy_resn <- data.frame(
  QSSTRESC = c(
    "GOOD", "FAIR", "RARELY", "NO",
    "SOME DIFFICULTY", "NO DIFFICULTY",
    "YES", "VERY DIFFICULT"
  ),
  QSSTRESN = c(1, 3, 4, 3, 2, 1, 1, 3)
)


# create dummy qs ====
dummy_qs <- data_frame(
  QSTEST = dummy_param,
  QSSTRESC = dummy_resc
) %>%
  left_join(., dummy_resn, by = "QSSTRESC") %>%
  mutate(
    QSORRES = QSSTRESC,
    QSTESTCD = paste0("VFQ", row_number()),
    QSCAT = "NEI VFQ-25",
    QSSCAT = "Original Response"
  )



# merge standard QS with parameters and result variables from temp QS data
qs2 <- merge(qs1, dummy_qs) %>%
  group_by(USUBJID) %>%
  # create QSSEQ based on VFQ QS parameters
  mutate(QSSEQ = row_number()) %>%
  arrange(USUBJID, QSSEQ) %>%
  select(
    STUDYID, DOMAIN, USUBJID, QSSEQ, QSTESTCD, QSTEST, QSCAT, QSSCAT,
    QSORRES, QSSTRESC, QSSTRESN, QSBLFL, VISITNUM,
    VISIT, VISITDY, QSDTC, QSDY
  )

# output admiralophtha_qs.RDS
saveRDS(qs2, file = "inst/extdata/admiralophtha_qs.RDS")
