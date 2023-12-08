# Name: ADBCVA
#
# Label: Best Corrected Visual Acuity Analysis Dataset
#
# Input: adsl, oe

library(admiral)
library(pharmaversesdtm)
library(admiralophtha)
library(dplyr)
library(lubridate)
library(stringr)

# ---- Load source datasets ----

# Use e.g. `haven::read_sas()` to read in .sas7bdat, or other suitable functions
# as needed and assign to the variables below.
# For illustration purposes read in admiral test data

data("oe_ophtha")
data("admiral_adsl")

# Add STUDYEYE to ADSL to simulate an ophtha dataset
adsl <- admiral_adsl %>%
  as.data.frame() %>%
  mutate(STUDYEYE = sample(c("LEFT", "RIGHT"), n(), replace = TRUE)) %>%
  convert_blanks_to_na()

oe <- convert_blanks_to_na(oe_ophtha) %>%
  ungroup()

# ---- Lookup tables ----

# Assign PARAMCD, PARAM, and PARAMN
param_lookup <- tibble::tribble(
  ~OETESTCD, ~OECAT, ~OESCAT, ~AFEYE, ~PARAMCD, ~PARAM, ~PARAMN,
  "VACSCORE", "BEST CORRECTED VISUAL ACUITY", "OVERALL EVALUATION", "Study Eye", "SBCVA", "Study Eye Visual Acuity Score (letters)", 1, # nolint
  "VACSCORE", "BEST CORRECTED VISUAL ACUITY", "OVERALL EVALUATION", "Fellow Eye", "FBCVA", "Fellow Eye Visual Acuity Score (letters)", 2, # nolint
)

# Assign AVALCAT1
avalcat_lookup <- tibble::tribble(
  ~PARAMCD, ~AVALCA1N, ~AVALCAT1,
  "SBCVA", 1000, "< 20/800",
  "SBCVA", 800, "20/800",
  "SBCVA", 640, "20/640",
  "SBCVA", 500, "20/500",
  "SBCVA", 400, "20/400",
  "SBCVA", 320, "20/320",
  "SBCVA", 250, "20/250",
  "SBCVA", 200, "20/200",
  "SBCVA", 160, "20/160",
  "SBCVA", 125, "20/125",
  "SBCVA", 100, "20/100",
  "SBCVA", 80, "20/80",
  "SBCVA", 63, "20/63",
  "SBCVA", 50, "20/50",
  "SBCVA", 40, "20/40",
  "SBCVA", 32, "20/32",
  "SBCVA", 25, "20/25",
  "SBCVA", 20, "20/20",
  "SBCVA", 16, "20/16",
  "SBCVA", 12, "20/12",
  "SBCVA", 1, "> 20/12",
)

# add equivalent rows for PARAMCD = "FBCVA"
avalcat_lookup <- avalcat_lookup %>%
  mutate(PARAMCD = "FBCVA") %>%
  rbind(avalcat_lookup)

# ---- Utility functions ----

# Format function for AVALCAT1
format_avalcat1n <- function(param, aval) {
  case_when(
    param %in% c("SBCVA", "FBCVA") & aval >= 0 & aval <= 3 ~ 1000,
    param %in% c("SBCVA", "FBCVA") & aval >= 4 & aval <= 8 ~ 800,
    param %in% c("SBCVA", "FBCVA") & aval >= 9 & aval <= 13 ~ 640,
    param %in% c("SBCVA", "FBCVA") & aval >= 14 & aval <= 18 ~ 500,
    param %in% c("SBCVA", "FBCVA") & aval >= 19 & aval <= 23 ~ 400,
    param %in% c("SBCVA", "FBCVA") & aval >= 24 & aval <= 28 ~ 320,
    param %in% c("SBCVA", "FBCVA") & aval >= 29 & aval <= 33 ~ 250,
    param %in% c("SBCVA", "FBCVA") & aval >= 34 & aval <= 38 ~ 200,
    param %in% c("SBCVA", "FBCVA") & aval >= 39 & aval <= 43 ~ 160,
    param %in% c("SBCVA", "FBCVA") & aval >= 44 & aval <= 48 ~ 125,
    param %in% c("SBCVA", "FBCVA") & aval >= 49 & aval <= 53 ~ 100,
    param %in% c("SBCVA", "FBCVA") & aval >= 54 & aval <= 58 ~ 80,
    param %in% c("SBCVA", "FBCVA") & aval >= 59 & aval <= 63 ~ 63,
    param %in% c("SBCVA", "FBCVA") & aval >= 64 & aval <= 68 ~ 50,
    param %in% c("SBCVA", "FBCVA") & aval >= 69 & aval <= 73 ~ 40,
    param %in% c("SBCVA", "FBCVA") & aval >= 74 & aval <= 78 ~ 32,
    param %in% c("SBCVA", "FBCVA") & aval >= 79 & aval <= 83 ~ 25,
    param %in% c("SBCVA", "FBCVA") & aval >= 84 & aval <= 88 ~ 20,
    param %in% c("SBCVA", "FBCVA") & aval >= 89 & aval <= 93 ~ 16,
    param %in% c("SBCVA", "FBCVA") & aval >= 94 & aval <= 97 ~ 12,
    param %in% c("SBCVA", "FBCVA") & aval >= 98 ~ 1
  )
}

# ---- Derivations ----

# Get list of ADSL vars required for derivations
adsl_vars <- exprs(TRTSDT, TRTEDT, TRT01A, TRT01P, STUDYEYE)

adbcva_adslvar <- oe %>%
  # Keep only BCVA parameters
  filter(
    OETESTCD %in% c("VACSCORE")
  ) %>%
  # Join ADSL with OE (need TRTSDT and STUDYEYE for ADY, AFEYE, and PARAMCD derivation)
  derive_vars_merged(
    dataset_add = adsl,
    new_vars = adsl_vars,
    by_vars = exprs(STUDYID, USUBJID)
  )

adbcva_aval <- adbcva_adslvar %>%
  # Calculate AVAL, AVALU and DTYPE
  mutate(
    AVAL = OESTRESN,
    AVALU = "letters",
    DTYPE = NA_character_
  ) %>%
  # Derive AFEYE needed for PARAMCD derivation
  derive_var_afeye(loc_var = OELOC, lat_var = OELAT)

adbcva_nlogparam <- adbcva_aval %>%
  # Add PARAM, PARAMCD for non log parameters
  derive_vars_merged(
    dataset_add = param_lookup,
    new_vars = exprs(PARAM, PARAMCD),
    by_vars = exprs(OETESTCD, AFEYE),
    filter_add = PARAMCD %in% c("SBCVA", "FBCVA")
  )

adbcva_logparam <- adbcva_nlogparam %>%
  # Add derived log parameters
  derive_param_computed(
    by_vars = c(exprs(STUDYID, USUBJID, VISIT, VISITNUM, OEDY, OEDTC, AFEYE), adsl_vars),
    parameters = c("SBCVA"),
    set_values_to = exprs(
      AVAL = convert_etdrs_to_logmar(AVAL.SBCVA),
      PARAMCD = "SBCVALOG",
      PARAM = "Study Eye Visual Acuity LogMAR Score",
      DTYPE = NA_character_,
      AVALU = "LogMAR"
    )
  ) %>%
  derive_param_computed(
    by_vars = c(exprs(STUDYID, USUBJID, VISIT, OEDY, OEDTC, AFEYE), adsl_vars),
    parameters = c("FBCVA"),
    set_values_to = exprs(
      AVAL = convert_etdrs_to_logmar(AVAL.FBCVA),
      PARAMCD = "FBCVALOG",
      PARAM = "Fellow Eye Visual Acuity LogMAR Score",
      DTYPE = NA_character_,
      AVALU = "LogMAR"
    )
  ) %>%
  mutate(AVALC = as.character(AVAL)) %>%
  # Calculate ADT, ADY
  derive_vars_dt(
    new_vars_prefix = "A",
    dtc = OEDTC,
    flag_imputation = "none"
  ) %>%
  derive_vars_dy(reference_date = TRTSDT, source_vars = exprs(ADT))

adbcva_visit <- adbcva_logparam %>%
  # Derive visit info and BASETYPE
  mutate(
    ATPTN = OETPTNUM,
    ATPT = OETPT,
    AVISIT = case_when(
      str_detect(VISIT, "SCREEN") ~ "Screening",
      !is.na(VISIT) ~ str_to_title(VISIT),
      TRUE ~ NA_character_
    ),
    AVISITN = round(VISITNUM, 0),
    BASETYPE = "LAST"
  )

# Derive Treatment flags
adbcva_trtflag <- adbcva_visit %>%
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
adbcva_vstflag <- adbcva_trtflag %>%
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
  ) %>%
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
  ) %>%
  # WORS01FL: Flag worst result within a PARAMCD for baseline & post-baseline records.
  # If worst result is highest result, change mode to "last"
  restrict_derivation(
    derivation = derive_var_extreme_flag,
    args = params(
      by_vars = exprs(USUBJID, PARAMCD),
      order = exprs(AVAL, ADT),
      new_var = WORS01FL,
      mode = "first"
    ),
    filter = !is.na(AVISITN) & (ONTRTFL == "Y" | ABLFL == "Y") & PARAMCD %in% c("FBCVA", "SBCVA")
  )

# Derive baseline information
adbcva_change <- adbcva_vstflag %>%
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

# Assign ASEQ
adbcva_aseq <- adbcva_change %>%
  derive_var_obs_number(
    new_var = ASEQ,
    by_vars = exprs(STUDYID, USUBJID),
    order = exprs(PARAMCD, ADT, AVISITN, VISITNUM, ATPTN),
    check_type = "error"
  )

# Add all ADSL variables
adbcva_adsl <- adbcva_aseq %>%
  derive_vars_merged(
    dataset_add = select(adsl, !!!negate_vars(adsl_vars)),
    by_vars = exprs(STUDYID, USUBJID)
  )

adbcva_crtflag <- adbcva_adsl %>%
  # Add criterion flags for BCVA endpoints
  restrict_derivation(
    derivation = derive_var_bcvacritxfl,
    args = params(
      crit_var = exprs(CHG),
      bcva_ranges = list(c(0, 5), c(-5, -1), c(10, 15)),
      bcva_uplims = list(-20, 5, 10),
      bcva_lowlims = list(-15, 15),
      additional_text = ""
    ),
    filter = PARAMCD %in% c("SBCVA", "FBCVA")
  ) %>%
  # Add AVALCATx variables
  mutate(AVALCA1N = format_avalcat1n(param = PARAMCD, aval = AVAL)) %>%
  derive_vars_merged(
    avalcat_lookup,
    by = exprs(PARAMCD, AVALCA1N)
  )

# Final Steps, Select final variables and Add labels
# This process will be based on your metadata, no example given for this reason
# ...

admiralophtha_adbcva <- adbcva_crtflag

# Save output ----

dir <- tools::R_user_dir("admiralophtha_templates_data", which = "cache")
# Change to whichever directory you want to save the dataset in
if (!file.exists(dir)) {
  # Create the folder
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
}
save(admiralophtha_adbcva, file = file.path(dir, "adbcva.rda"), compress = "bzip2")
