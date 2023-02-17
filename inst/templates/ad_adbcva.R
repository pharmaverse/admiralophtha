# Name: ADBCVA
#
# Label: Best Corrected Visual Acuity Analysis Dataset
#
# Input: adsl, oe

library(admiral)
library(admiral.test) # Contains example datasets from the CDISC pilot project
library(dplyr)
library(lubridate)
library(stringr)

# ---- Load source datasets ----

# Use e.g. `haven::read_sas()` to read in .sas7bdat, or other suitable functions
# as needed and assign to the variables below.
# For illustration purposes read in admiral test data

data("admiral_oe") # when this exists!
data("admiral_adsl") # can't use this yet as ADSL needs STUDYEYE

# Add STUDYEYE to ADSL to simulate an ophtha dataset
adsl <- admiral_adsl %>%
  as.data.frame() %>%
  mutate(STUDYEYE = sample(c("LEFT", "RIGHT"), n(), replace = TRUE)) %>%
  convert_blanks_to_na()

oe <- convert_blanks_to_na(admiral_oe) %>% ungroup()

# ---- Lookup tables ----

# Assign PARAMCD, PARAM, and PARAMN
param_lookup <- tibble::tribble(
  ~OETESTCD, ~OELAT, ~STUDYEYE, ~PARAMCD, ~PARAM, ~PARAMN,
  "VACSCORE", "RIGHT", "RIGHT", "SBCVA", "Study Eye Visual Acuity Score", 1,
  "VACSCORE", "LEFT", "LEFT", "SBCVA", "Study Eye Visual Acuity Score", 1,
  "VACSCORE", "RIGHT", "LEFT", "FBCVA", "Fellow Eye Visual Acuity Score", 2,
  "VACSCORE", "LEFT", "RIGHT", "FBCVA", "Fellow Eye Visual Acuity Score", 2,
  "VACSCORE", "RIGHT", "RIGHT", "SBCVALOG", "Study Eye Visual Acuity LogMAR Score", 3,
  "VACSCORE", "LEFT", "LEFT", "SBCVALOG", "Study Eye Visual Acuity LogMAR Score", 3,
  "VACSCORE", "RIGHT", "LEFT", "FBCVALOG", "Fellow Eye Visual Acuity LogMAR Score", 4,
  "VACSCORE", "LEFT", "RIGHT", "FBCVALOG", "Fellow Eye Visual Acuity LogMAR Score", 4
)
attr(param_lookup$OETESTCD, "label") <- "Ophthalmology Test Short Name"

# ---- Derivations ----

# Get list of ADSL vars required for derivations
adsl_vars <- exprs(TRTSDT, TRTEDT, TRT01A, TRT01P, STUDYEYE)

adbcva <- oe %>%
  # Keep only BCVA parameters
  filter(
    OETESTCD %in% c("VACSCORE")
  ) %>%
  # Join ADSL with OE (need TRTSDT and STUDYEYE for ADY and PARAMCD derivation)
  derive_vars_merged(
    dataset_add = adsl,
    new_vars = adsl_vars,
    by_vars = exprs(STUDYID, USUBJID)
  ) %>%
  # Calculate ADT, ADY
  derive_vars_dt(
    new_vars_prefix = "A",
    dtc = OEDTC,
    flag_imputation = "none"
  ) %>%
  derive_vars_dy(reference_date = TRTSDT, source_vars = exprs(ADT))

# Add PARAM, PARAMCD - needs to be done separately for log/nonlog parameters
adbcva_etdrs <- adbcva %>%
  derive_vars_merged(
    dataset_add = param_lookup,
    new_vars = exprs(PARAM, PARAMCD),
    by_vars = exprs(OETESTCD, OELAT, STUDYEYE),
    filter_add = PARAMCD %in% c("SBCVA", "FBCVA")
  )

adbcva_log <- adbcva %>%
  derive_vars_merged(
    dataset_add = param_lookup,
    new_vars = exprs(PARAM, PARAMCD),
    by_vars = exprs(OETESTCD, OELAT, STUDYEYE),
    filter_add = PARAMCD %in% c("SBCVALOG", "FBCVALOG")
  )

adbcva <- rbind(adbcva_etdrs, adbcva_log)

adbcva <- adbcva %>%
  # Calculate AVAL, AVALU and AVALC
  mutate(
    AVAL = case_when(
      PARAMCD %in% c("SBCVA", "FBCVA") ~ OESTRESN,
      PARAMCD %in% c("SBCVALOG", "FBCVALOG") ~ calculate_etdrs_to_logmar(OESTRESN)
      ),
    AVALU = case_when(
      PARAMCD %in% c("SBCVA", "FBCVA") ~ "ETDRS Score (letters)",
      PARAMCD %in% c("SBCVALOG", "FBCVALOG") ~ "LogMAR"
    ),
    AVALC = as.character(OESTRESN)
  )

# Derive visit info - no ATPT and ATPTN yet as SDTM variables not in test data
adbcva <- adbcva %>%
  mutate(
    ATPTN = OETPTNUM,
    ATPT = OETPT,
    AVISIT = case_when(
      str_detect(VISIT, "SCREEN") ~ "Screening",
      !is.na(VISIT) ~ str_to_title(VISIT),
      TRUE ~ NA_character_
    ),

    AVISITN = round(VISITNUM, 0)
  )

# Derive DTYPE and BASETYPE
adbcva <- adbcva %>%
  mutate(
    DTYPE = NA_character_,
    BASETYPE = "LAST"
  )

# Derive Treatment flags
adbcva <- adbcva %>%
  # Calculate ONTRTFL
  derive_var_ontrtfl(
    start_date = ADT,
    ref_start_date = TRTSDT,
    ref_end_date = TRTEDT,
    filter_pre_timepoint = AVISIT == "Baseline"
  ) %>%
  # Calculate ABLFL
  restrict_derivation(
    derivation = derive_var_extreme_flag,
    args = params(
      new_var = ABLFL,
      by_vars = exprs(STUDYID, USUBJID, BASETYPE, PARAMCD),
      order = exprs(ADT, VISITNUM, OESEQ),
      mode = "last"
    ),
    filter = (!is.na(AVAL) & ADT <= TRTSDT & !is.na(BASETYPE))
  )

# Derive visit flags
adbcva <- adbcva %>%
  # ANL01FL: Flag last result within a visit and timepoint for baseline and post-baseline records
  restrict_derivation(
    derivation = derive_var_extreme_flag,
    args = params(
      new_var = ANL01FL,
      by_vars = exprs(USUBJID, PARAMCD, AVISIT, DTYPE),
      order = exprs(ADT, AVAL),
      mode = "last"
    ),
    filter = !is.na(AVISITN) & (ONTRTFL == "Y" | ABLFL == "Y")
  )  %>%
  # ANL02FL: Flag last result within a PARAMCD for baseline & post-baseline records
  restrict_derivation(
    derivation = derive_var_extreme_flag,
    args = params(
      new_var = ANL02FL,
      by_vars = exprs(USUBJID, PARAMCD, ABLFL),
      order = exprs(ADT),
      mode = "last"
    ),
    filter = !is.na(AVISITN) & (ONTRTFL == "Y" | ABLFL == "Y")
  )  %>%
  # WORS01FL: Flag worst result with an
  restrict_derivation(
    derivation = derive_var_worst_flag,
    args = params(
      new_var = WORS01FL,
      by_vars = exprs(USUBJID, PARAMCD),
      order = exprs(desc(ADT)),
      param_var = PARAMCD,
      analysis_var = AVAL,
      worst_high =  character(0), # put character(0) if no PARAMCDs here
      worst_low = c("FBCVA", "SBCVA")    # put character(0) if no PARAMCDs here
    ),
    filter = !is.na(AVISITN) & ONTRTFL == "Y"
  )

# Derive baseline information
adbcva <- adbcva %>%
  # Calculate BASE
  derive_var_base(
    by_vars = exprs(STUDYID, USUBJID, PARAMCD, BASETYPE),
    source_var = AVAL,
    new_var = BASE
  ) %>%
  # Calculate BASEC
  derive_var_base(
    by_vars = exprs(STUDYID, USUBJID, PARAMCD, BASETYPE),
    source_var = AVALC,
    new_var = BASEC
  ) %>%
  # Calculate CHG
  derive_var_chg() %>%
  # Calculate PCHG
  derive_var_pchg()

# Add all ADSL variables
adbcva <- adbcva %>%
  derive_vars_merged(
    dataset_add = select(adsl, !!!negate_vars(adsl_vars)),
    by_vars = exprs(STUDYID, USUBJID)
  )

# Add criterion flags for BCVA endpoints
adbcva <- adbcva %>%
  derive_var_bcvacritxfl(
    paramcds = c("SBCVA", "FBCVA"),
    basetype = NULL,
    bcva_ranges = list(c(0, 5), c(-5, -1), c(10, 15)),
    bcva_uplims = list(-20, 5, 10),
    bcva_lowlims = list(-15, 15),
    additional_text = ""
  )

# Final Steps, Select final variables and Add labels
# This process will be based on your metadata, no example given for this reason
# ...

# ---- Save output ----

dir <- tempdir() # Change to whichever directory you want to save the dataset in
save(adbcva, file = file.path(dir, "adbcva.rda"), compress = "bzip2")
