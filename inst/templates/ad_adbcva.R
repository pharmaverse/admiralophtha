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

# SBCVA and FBCVA definition list
# This can be sourced from a separate R script
definition_bcva <- exprs(
  ~PARAMCD, ~condition, ~AVALCA1N, ~AVALCAT1,
  "SBCVA", AVAL >= 0 & AVAL <= 3, 1000, "< 20/800",
  "FBCVA", AVAL >= 0 & AVAL <= 3, 1000, "< 20/800",
  "SBCVA", AVAL >= 4 & AVAL <= 8, 800, "20/800",
  "FBCVA", AVAL >= 4 & AVAL <= 8, 800, "20/800",
  "SBCVA", AVAL >= 9 & AVAL <= 13, 640, "20/640",
  "FBCVA", AVAL >= 9 & AVAL <= 13, 640, "20/640",
  "SBCVA", AVAL >= 14 & AVAL <= 18, 500, "20/500",
  "FBCVA", AVAL >= 14 & AVAL <= 18, 500, "20/500",
  "SBCVA", AVAL >= 19 & AVAL <= 23, 400, "20/400",
  "FBCVA", AVAL >= 19 & AVAL <= 23, 400, "20/400",
  "SBCVA", AVAL >= 24 & AVAL <= 28, 320, "20/320",
  "FBCVA", AVAL >= 24 & AVAL <= 28, 320, "20/320",
  "SBCVA", AVAL >= 29 & AVAL <= 33, 250, "20/250",
  "FBCVA", AVAL >= 29 & AVAL <= 33, 250, "20/250",
  "SBCVA", AVAL >= 34 & AVAL <= 38, 200, "20/200",
  "FBCVA", AVAL >= 34 & AVAL <= 38, 200, "20/200",
  "SBCVA", AVAL >= 39 & AVAL <= 43, 160, "20/160",
  "FBCVA", AVAL >= 39 & AVAL <= 43, 160, "20/160",
  "SBCVA", AVAL >= 44 & AVAL <= 48, 125, "20/125",
  "FBCVA", AVAL >= 44 & AVAL <= 48, 125, "20/125",
  "SBCVA", AVAL >= 49 & AVAL <= 53, 100, "20/100",
  "FBCVA", AVAL >= 49 & AVAL <= 53, 100, "20/100",
  "SBCVA", AVAL >= 54 & AVAL <= 58, 80, "20/80",
  "FBCVA", AVAL >= 54 & AVAL <= 58, 80, "20/80",
  "SBCVA", AVAL >= 59 & AVAL <= 63, 63, "20/63",
  "FBCVA", AVAL >= 59 & AVAL <= 63, 63, "20/63",
  "SBCVA", AVAL >= 64 & AVAL <= 68, 50, "20/50",
  "FBCVA", AVAL >= 64 & AVAL <= 68, 50, "20/50",
  "SBCVA", AVAL >= 69 & AVAL <= 73, 40, "20/40",
  "FBCVA", AVAL >= 69 & AVAL <= 73, 40, "20/40",
  "SBCVA", AVAL >= 74 & AVAL <= 78, 32, "20/32",
  "FBCVA", AVAL >= 74 & AVAL <= 78, 32, "20/32",
  "SBCVA", AVAL >= 79 & AVAL <= 83, 25, "20/25",
  "FBCVA", AVAL >= 79 & AVAL <= 83, 25, "20/25",
  "SBCVA", AVAL >= 84 & AVAL <= 88, 20, "20/20",
  "FBCVA", AVAL >= 84 & AVAL <= 88, 20, "20/20",
  "SBCVA", AVAL >= 89 & AVAL <= 93, 16, "20/16",
  "FBCVA", AVAL >= 89 & AVAL <= 93, 16, "20/16",
  "SBCVA", AVAL >= 94 & AVAL <= 97, 12, "20/12",
  "FBCVA", AVAL >= 94 & AVAL <= 97, 12, "20/12",
  "SBCVA", AVAL >= 98, 1, "> 20/12",
  "FBCVA", AVAL >= 98, 1, "> 20/12"
)

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
    by_vars = get_admiral_option("subject_keys")
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
    by_vars = c(
      get_admiral_option("subject_keys"),
      exprs(VISIT, VISITNUM, OEDY, OEDTC, AFEYE, !!!adsl_vars)
    ),
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
    by_vars = c(
      get_admiral_option("subject_keys"),
      exprs(VISIT, VISITNUM, OEDY, OEDTC, AFEYE, !!!adsl_vars)
    ),
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
      by_vars = c(get_admiral_option("subject_keys"), exprs(BASETYPE, PARAMCD)),
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
      by_vars = c(get_admiral_option("subject_keys"), exprs(PARAMCD, AVISIT, DTYPE)),
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
      by_vars = c(get_admiral_option("subject_keys"), exprs(PARAMCD, ABLFL)),
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
      by_vars = c(get_admiral_option("subject_keys"), exprs(PARAMCD)),
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
    by_vars = c(get_admiral_option("subject_keys"), exprs(PARAMCD, BASETYPE)),
    source_var = AVAL,
    new_var = BASE
  ) %>%
  # Calculate BASEC
  derive_var_base(
    by_vars = c(get_admiral_option("subject_keys"), exprs(PARAMCD, BASETYPE)),
    source_var = AVALC,
    new_var = BASEC
  ) %>%
  # Calculate CHG
  derive_var_chg() %>%
  # Calculate PCHG
  derive_var_pchg()


# Add criterion flags and AVALCATs for BCVA endpoints
adbcva_crtflag <- adbcva_change %>%
  restrict_derivation(
    derivation = call_derivation,
    filter = PARAMCD %in% c("SBCVA", "FBCVA"),
    args = params(
      derivation = derive_vars_crit_flag,
      variable_params = list(
        params(crit_nr = 1, condition = CHG >= 0 & CHG <= 5, description = "0 <= CHG <= 5"),
        params(crit_nr = 2, condition = CHG >= -5 & CHG <= -1, description = "-5 <= CHG <= -1"),
        params(crit_nr = 3, condition = CHG >= 10 & CHG <= 15, description = "10 <= CHG <= 15"),
        params(crit_nr = 4, condition = CHG <= -20, description = "CHG <= -20"),
        params(crit_nr = 5, condition = CHG <= 5, description = "CHG <= 5"),
        params(crit_nr = 6, condition = CHG <= 10, description = "CHG <= 10"),
        params(crit_nr = 7, condition = CHG >= -15, description = "CHG >= -15"),
        params(crit_nr = 8, condition = CHG >= 15, description = "CHG >= 15")
      ),
      values_yn = TRUE
    )
  ) %>%
  # Add AVALCATx variables
  derive_vars_cat(
    definition = definition_bcva,
    by_vars = exprs(PARAMCD)
  )

# Assign ASEQ
adbcva_aseq <- adbcva_crtflag %>%
  derive_var_obs_number(
    new_var = ASEQ,
    by_vars = get_admiral_option("subject_keys"),
    order = exprs(PARAMCD, ADT, AVISITN, VISITNUM, ATPTN),
    check_type = "error"
  )

# Add all ADSL variables
adbcva_adsl <- adbcva_aseq %>%
  derive_vars_merged(
    dataset_add = select(adsl, !!!negate_vars(adsl_vars)),
    by_vars = get_admiral_option("subject_keys")
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
