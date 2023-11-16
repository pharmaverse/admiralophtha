# Name: ADVFQ
#
# Label: VFQ Analysis Dataset
#
# Input: adsl, qs
library(admiral)
library(dplyr, warn.conflicts = FALSE)
library(pharmaversesdtm)
library(stringr)
library(tibble)

data("admiral_adsl")
data("qs_ophtha")

adsl <- admiral_adsl
qs <- qs_ophtha

qs <- convert_blanks_to_na(qs)

qs <- qs %>% filter(QSTESTCD %in% c("VFQ1", "VFQ2", "VFQ3", "VFQ4"))


# Assign PARAMCD, PARAM, and PARAMN
param_lookup <- tibble::tribble(
  ~QSTESTCD, ~PARAMCD, ~PARAM, ~PARCAT1, ~PARCAT2,
  "VFQ1", "VFQ1", "Overall Health", "NEI VFQ-25", "Original Response",
  "VFQ2", "VFQ2", "Eyesight in Both Eyes", "NEI VFQ-25", "Original Response",
  "VFQ3", "VFQ3", "Worry About Eyesight", "NEI VFQ-25", "Original Response",
  "VFQ4", "VFQ4", "Pain in and Around Eyes", "NEI VFQ-25", "Original Response",
  "QR01", "QR01", "Recoded Item - 01", "NEI VFQ-25", "General 01",
  "QR02", "QR02", "Recoded Item - 02", "NEI VFQ-25", "General 01",
  "QR03", "QR03", "Recoded Item - 03", "NEI VFQ-25", "General 02",
  "QR04", "QR04", "Recoded Item - 04", "NEI VFQ-25", "General 02",
  "QSG01", "QSG01", "General Score 01", "NEI VFQ-25", "Averaged Result",
  "QSG02", "QSG02", "General Score 02", "NEI VFQ-25", "Averaged Result",
  "QBCSCORE", "QBCSCORE", "Composite Score", "NEI VFQ-25", "Averaged Result"
)
attr(param_lookup$QSTESTCD, "label") <- "Question Short Name"

adsl_vars <- exprs(TRTSDT, TRTEDT, TRT01A, TRT01P)

advfq_dtdy <- derive_vars_merged(
  ungroup(qs),
  dataset_add = adsl,
  new_vars = adsl_vars,
  by_vars = exprs(STUDYID, USUBJID)
) %>%
  ## Calculate ADT, ADY ----
  derive_vars_dt(
    new_vars_prefix = "A",
    dtc = QSDTC
  ) %>%
  derive_vars_dy(reference_date = TRTSDT, source_vars = exprs(ADT))

advfq_aval <- advfq_dtdy %>%
  ## Add PARAMCD only - add PARAM etc later ----
  derive_vars_merged_lookup(
    dataset_add = param_lookup,
    new_vars = exprs(PARAMCD),
    by_vars = exprs(QSTESTCD)
  ) %>%
  ## Calculate AVAL and AVALC ----
  mutate(
    AVAL = QSSTRESN,
    AVALC = QSORRES
  )

## Derive new parameters based on existing records ----

## QR01 Recoded Item 01
# set to 100 if [advfq.AVAL] = 1
# else set to 75 if [advfq.AVAL] = 2
# else set to 50 if [advfq.AVAL] = 3
# else set to 25 if [advfq.AVAL] = 4
# else set to 0 if [advfq.AVAL] = 5
advfq_qr01 <- advfq_aval %>%
  derive_summary_records(
    by_vars = exprs(STUDYID, USUBJID, !!!adsl_vars, PARAMCD, VISITNUM, VISIT, ADT, ADY),
    filter = QSTESTCD == "VFQ1" & !is.na(AVAL),
    analysis_var = AVAL,
    summary_fun = identity,
    set_values_to = exprs(PARAMCD = "QR01")
  ) %>%
  mutate(AVAL = ifelse(PARAMCD == "QR01",
    case_when(
      AVAL == 1 ~ 100,
      AVAL == 2 ~ 75,
      AVAL == 3 ~ 50,
      AVAL == 4 ~ 25,
      AVAL >= 5 ~ 0
    ),
    AVAL
  ))

## QR02 Recoded Item 02
# set to 100 if [advfq.AVAL] = 1
# else set to 80 if [advfq.AVAL] = 2
# else set to 60 if [advfq.AVAL] = 3
# else set to 40 if [advfq.AVAL] = 4
# else set to 20 if [advfq.AVAL] = 5
# else set to 0 if [advfq.AVAL] = 6
advfq_qr02 <- advfq_qr01 %>%
  derive_summary_records(
    by_vars = exprs(STUDYID, USUBJID, !!!adsl_vars, PARAMCD, VISITNUM, VISIT, ADT, ADY),
    filter = QSTESTCD == "VFQ2" & !is.na(AVAL),
    analysis_var = AVAL,
    summary_fun = identity,
    set_values_to = exprs(PARAMCD = "QR02")
  ) %>%
  mutate(AVAL = ifelse(PARAMCD == "QR02",
    case_when(
      AVAL == 1 ~ 100,
      AVAL == 2 ~ 80,
      AVAL == 3 ~ 60,
      AVAL == 4 ~ 40,
      AVAL == 5 ~ 20,
      AVAL >= 6 ~ 0
    ),
    AVAL
  ))

## QR03 Recoded Item 03
# set to 100 if [advfq.AVAL] = 5
# else set to 75 if [advfq.AVAL] = 4
# else set to 50 if [advfq.AVAL] = 3
# else set to 25 if [advfq.AVAL] = 2
# else set to 0 if [advfq.AVAL] = 1
advfq_qr03 <- advfq_qr02 %>%
  derive_summary_records(
    by_vars = exprs(STUDYID, USUBJID, PARAMCD, !!!adsl_vars, VISITNUM, VISIT, ADT, ADY),
    filter = QSTESTCD == "VFQ3" & !is.na(AVAL),
    analysis_var = AVAL,
    summary_fun = identity,
    set_values_to = exprs(PARAMCD = "QR03")
  ) %>%
  mutate(AVAL = ifelse(PARAMCD == "QR03",
    case_when(
      AVAL == 1 ~ 0,
      AVAL == 2 ~ 25,
      AVAL == 3 ~ 50,
      AVAL == 4 ~ 75,
      AVAL >= 5 ~ 100
    ),
    AVAL
  ))


## QR04 Recoded Item 04
# set to 100 if [advfq.AVAL] = 5
# else set to 75 if [advfq.AVAL] = 4
# else set to 50 if [advfq.AVAL] = 3
# else set to 25 if [advfq.AVAL] = 2
# else set to 0 if [advfq.AVAL] = 1
advfq_qr04 <- advfq_qr03 %>%
  derive_summary_records(
    by_vars = exprs(STUDYID, USUBJID, PARAMCD, !!!adsl_vars, VISITNUM, VISIT, ADT, ADY),
    filter = QSTESTCD == "VFQ4" & !is.na(AVAL),
    analysis_var = AVAL,
    summary_fun = identity,
    set_values_to = exprs(PARAMCD = "QR04")
  ) %>%
  mutate(AVAL = ifelse(PARAMCD == "QR04",
    case_when(
      AVAL <= 1 ~ 0,
      AVAL == 2 ~ 25,
      AVAL == 3 ~ 50,
      AVAL == 4 ~ 75,
      AVAL >= 5 ~ 100
    ),
    AVAL
  ))

## Derive a new record as a summary record  ----
## QSG01 General Score 01
# Average of QR01 and QR02 records
advfq_qsg01 <- advfq_qr04 %>%
  derive_summary_records(
    by_vars = exprs(STUDYID, USUBJID, !!!adsl_vars, VISITNUM, VISIT, ADT, ADY),
    filter = PARAMCD %in% c("QR01", "QR02") & !is.na(AVAL),
    analysis_var = AVAL,
    summary_fun = mean,
    set_values_to = exprs(PARAMCD = "QSG01")
  )

## Derive a new record as a summary record  ----
## QSG02 General Score 02
# Average of QR03 and QR04 records
advfq_qsg02 <- advfq_qsg01 %>%
  derive_summary_records(
    by_vars = exprs(STUDYID, USUBJID, !!!adsl_vars, VISITNUM, VISIT, ADT, ADY),
    filter = PARAMCD %in% c("QR03", "QR04") & !is.na(AVAL),
    analysis_var = AVAL,
    summary_fun = mean,
    set_values_to = exprs(PARAMCD = "QSG02")
  )


## Derive a new record as a summary record  ----
## QBCSCORE Composite Score
# Average of QSG01 and QSG02 records
advfq_qbcs <- advfq_qsg02 %>%
  derive_summary_records(
    by_vars = exprs(STUDYID, USUBJID, !!!adsl_vars, VISITNUM, VISIT, ADT, ADY),
    filter = PARAMCD %in% c("QSG01", "QSG02") & !is.na(AVAL),
    analysis_var = AVAL,
    summary_fun = sum,
    set_values_to = exprs(PARAMCD = "QBCSCORE")
  )

## Get visit info ----
# See also the "Visit and Period Variables" vignette
# (https://pharmaverse.github.io/admiral/cran-release/articles/visits_periods.html)
advfq_visit <- advfq_qbcs %>%
  # Derive Timing
  mutate(
    AVISIT = case_when(
      str_detect(VISIT, "SCREEN|UNSCHED|RETRIEVAL|AMBUL") ~ NA_character_,
      # If VISIT=DAY 1 then set to Baseline, study specific
      str_detect(VISIT, "DAY 1") ~ "Baseline",
      !is.na(VISIT) ~ str_to_title(VISIT),
      TRUE ~ NA_character_
    ),
    AVISITN = as.numeric(case_when(
      VISIT == "BASELINE" ~ "0",
      str_detect(VISIT, "WEEK") ~ str_trim(str_replace(VISIT, "WEEK", "")),
      TRUE ~ NA_character_
    ))
  )

advfq_ontrt <- advfq_visit %>%
  ## Calculate ONTRTFL ----
  derive_var_ontrtfl(
    start_date = ADT,
    ref_start_date = TRTSDT,
    ref_end_date = TRTEDT,
    filter_pre_timepoint = AVISIT == "Baseline"
  )

## Derive baseline flags ----
advfq_blfl <- advfq_ontrt %>%
  # Calculate ABLFL
  restrict_derivation(
    derivation = derive_var_extreme_flag,
    args = params(
      by_vars = exprs(STUDYID, USUBJID, PARAMCD),
      order = exprs(ADT, VISITNUM, QSSEQ),
      new_var = ABLFL,
      mode = "last"
    ),
    filter = (!is.na(AVAL) &
      ADT <= TRTSDT)
  )

## Derive baseline information ----
advfq_change <- advfq_blfl %>%
  # Calculate BASE
  derive_var_base(
    by_vars = exprs(STUDYID, USUBJID, PARAMCD),
    source_var = AVAL,
    new_var = BASE
  ) %>%
  # Calculate CHG
  derive_var_chg() %>%
  # Calculate PCHG
  derive_var_pchg()


## ANL01FL: Flag last result within an AVISIT for post-baseline records ----
advfq_anlflag <- advfq_change %>%
  restrict_derivation(
    derivation = derive_var_extreme_flag,
    args = params(
      new_var = ANL01FL,
      by_vars = exprs(USUBJID, PARAMCD, AVISIT),
      order = exprs(ADT, AVAL),
      mode = "last"
    ),
    filter = !is.na(AVISITN) & ONTRTFL == "Y"
  )

## Get ASEQ and PARAM  ----
advfq_aseq <- advfq_anlflag %>%
  # Calculate ASEQ
  derive_var_obs_number(
    new_var = ASEQ,
    by_vars = exprs(STUDYID, USUBJID),
    order = exprs(PARAMCD, ADT, AVISITN, VISITNUM),
    check_type = "error"
  ) %>%
  # Derive PARAM
  derive_vars_merged(dataset_add = select(param_lookup, -QSTESTCD), by_vars = exprs(PARAMCD))


# Add all ADSL variables
advfq_adsl <- advfq_aseq %>%
  derive_vars_merged(
    dataset_add = select(adsl, !!!negate_vars(adsl_vars)),
    by_vars = exprs(STUDYID, USUBJID)
  )

# Final Steps, Select final variables and Add labels
# This process will be based on your metadata, no example given for this reason
# ...

admiralophtha_advfq <- advfq_adsl

# ---- Save output ----

# Save output ----

dir <- tools::R_user_dir("admiralophtha_templates_data", which = "cache")
if (!file.exists(dir)) {
  # Create the folder
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
}
save(admiralophtha_advfq, file = file.path(dir, "advfq.rda"), compress = "bzip2")
