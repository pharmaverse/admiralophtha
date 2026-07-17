# Name: ADGA
#
# Label: Geographic Atrophy  Analysis Dataset
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

# Assign PARAMCD, PARAM, andPARAMN
# nolint start
param_lookup <- tibble::tribble(
  ~OETESTCD, ~OECAT, ~OESCAT, ~AFEYE, ~PARAMCD, ~PARAM, ~PARAMN,
  "AREA", "OPHTHALMIC ASSESSMENTS", NA_character_, "Study Eye", "SAREAFAF", "Study Eye GA Area measured by FAF(mm2)", 1,
  "AREA", "OPHTHALMIC ASSESSMENTS", NA_character_, "Fellow Eye", "FAREAFAF", "Fellow Eye GA Area measured by FAF(mm2)", 2,
  "GAFLOC", "OPHTHALMIC ASSESSMENTS", NA_character_, "Study Eye", "SGAFOCAL", "Study Eye GA Lesion Focality", 3,
  "GAFLOC", "OPHTHALMIC ASSESSMENTS", NA_character_, "Fellow Eye", "FGAFOCAL", "Fellow Eye GA Lesion Focality", 4
)
# nolint end

# ---- Derivations ----

# Get list of ADSL vars required for derivations
adsl_vars <- exprs(TRTSDT, TRTEDT, TRT01A, TRT01P, STUDYEYE)

adga_adslvar <- oe %>%
  # Keep only GA related OE parameters
    filter(
    OETESTCD %in% c("AREA", "GAFLOC"),
    !is.na(OESTRESC)
    ) %>%
  # Join ADSL with OE (need TRTSDT and STUDYEYE for ADY, AFEYE, and PARAMCD derivation)
  derive_vars_merged(
    dataset_add = adsl,
    new_vars = adsl_vars,
    by_vars = get_admiral_option("subject_keys")
  )

adga_aval <- adga_adslvar %>%
  # Calculate AVAL, AVALC, AVALU and DTYPE
  mutate(
    AVAL = OESTRESN,
    AVALC = OESTRESC,
    AVALU = OESTRESU,
    DTYPE = NA_character_
  ) %>%
  # Derive AFEYE needed for PARAMCD derivation
  derive_var_afeye(loc_var = OELOC, lat_var = OELAT, loc_vals = c("EYE", "RETINA"))

adga_param <- adga_aval %>%
  # Add PARAM, PARAMCD, PARAMN
  derive_vars_merged(
    dataset_add = param_lookup,
    new_vars = exprs(PARAM, PARAMCD, PARAMN),
    by_vars = exprs(OETESTCD, AFEYE)
  ) %>%
  # Calculate ADT, ADY
  derive_vars_dt(
    new_vars_prefix = "A",
    dtc = OEDTC,
    flag_imputation = "none"
  ) %>%
  derive_vars_dy(reference_date = TRTSDT, source_vars = exprs(ADT))

adga_visit <- adga_param %>%
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

adga_derive <- adga_visit %>%
  # Add PARAM, PARAMCD for square root transformed parameters
  filter(PARAMCD %in% c("SAREAFAF", "FAREAFAF")) %>%
  rename(aval = AVAL) %>%
  mutate(
    PARAMCD = case_when(
      PARAMCD == "SAREAFAF"  ~ "SSQRTFAF",
      PARAMCD == "FAREAFAF"  ~ "FSQRTFAF"
    ),
    PARAM = case_when(
      PARAMCD == "SSQRTFAF"  ~ "Study Eye Square Root Transformed GA Area measured by FAF(mm)",
      PARAMCD == "FSQRTFAF"  ~ "Fellow Eye Square Root Transformed GA Area measured by FAF(mm)"
    ),
    PARAMN = case_when(
      PARAMCD == "SSQRTFAF"  ~ 5,
      PARAMCD == "FSQRTFAF"  ~ 6
    ),
    AVAL = sqrt(aval),
    AVALU = "mm"
  ) %>%
  select(-aval)

# Combine all parameters
adga_comb <- bind_rows(
  adga_visit,
  adga_derive
) %>%
  arrange(USUBJID, PARAMN, AVISITN)

# Derive Treatment flags
adga_trtflag <- adga_comb %>%
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
adga_vstflag <- adga_trtflag %>%
  # ANL01FL: Flag last result within a visit and timepoint for baseline and post-baseline records
  restrict_derivation(
    derivation = derive_var_extreme_flag,
    args = params(
      new_var = ANL01FL,
      by_vars = c(get_admiral_option("subject_keys"), exprs(PARAMCD, AVISIT, ATPT, DTYPE)),
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
      by_vars = c(get_admiral_option("subject_keys"), exprs(PARAMCD, ATPT, ABLFL)),
      order = exprs(ADT),
      mode = "last"
    ),
    filter = !is.na(AVISITN) & (ONTRTFL == "Y" | ABLFL == "Y")
  ) %>%
  # WORS01FL: Flag worst result within a PARAMCD for baseline & post-baseline records
  # If worst result is lowest result, change mode to "first"
  restrict_derivation(
    derivation = derive_var_extreme_flag,
    args = params(
      by_vars = c(get_admiral_option("subject_keys"), exprs(PARAMCD, ATPT)),
      order = exprs(AVAL, ADT),
      new_var = WORS01FL,
      mode = "last"
    ),
    filter = !is.na(AVISITN) & (ONTRTFL == "Y" | ABLFL == "Y") & PARAMCD %in% c("SSQRTFAF", "FSQRTFAF")
  )

# Derive baseline information
adga_change <- adga_vstflag %>%
  # Calculate BASE (do not derive for GA Lesion Focality params)
  restrict_derivation(
    derivation = derive_var_base,
    args = params(
      by_vars = c(get_admiral_option("subject_keys"), exprs(PARAMCD, ATPT, BASETYPE)),
      source_var = AVAL,
      new_var = BASE
    ),
    filter = !PARAMCD %in% c("SIOPCHG", "FIOPCHG")
  ) %>%
  # Calculate BASEC (do not derive for GA Lesion Focality params)
  restrict_derivation(
    derivation = derive_var_base,
    args = params(
      by_vars = c(get_admiral_option("subject_keys"), exprs(PARAMCD, ATPT, BASETYPE)),
      source_var = AVALC,
      new_var = BASEC
    ),
    filter = !PARAMCD %in% c("SGAFOCAL", "FGAFOCAL")
  ) %>%
  # Calculate CHG (not derived for GA Lesion Focality params as BASE is NA)
  derive_var_chg() %>%
  # Calculate PCHG (not derived for GA Lesion Focality params as BASE is NA)
  derive_var_pchg()

# Assign ASEQ
adga_aseq <- adga_change %>%
  derive_var_obs_number(
    new_var = ASEQ,
    by_vars = get_admiral_option("subject_keys"),
    order = exprs(PARAMN, ADT, AVISITN, VISITNUM, ATPTN),
    check_type = "error"
  )

# Add all ADSL variables
adga_adsl <- adga_aseq %>%
  derive_vars_merged(
    dataset_add = select(adsl, !!!negate_vars(adsl_vars)),
    by_vars = get_admiral_option("subject_keys")
  )

# Final Steps, Select final variables and Add labels
# This process will be based on your metadata, no example given for this reason
# ...

admiralophtha_adga <- adga_adsl

# Save output ----

dir <- tools::R_user_dir("admiralophtha_templates_data", which = "cache")
# Change to whichever directory you want to save the dataset in
if (!file.exists(dir)) {
  # Create the folder
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
}
save(admiralophtha_adga, file = file.path(dir, "adga.rda"), compress = "bzip2")
