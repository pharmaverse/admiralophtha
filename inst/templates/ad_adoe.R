# Name: ADOE
#
# Label: Ophthalmology Exam Analysis Dataset
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
  "CSUBTH", "OPHTHALMIC ASSESSMENTS", "SD-OCT CST SINGLE FORM", "Study Eye", "SCSUBTH", "Study Eye Center Subfield Thickness (um)", 1,
  "CSUBTH", "OPHTHALMIC ASSESSMENTS", "SD-OCT CST SINGLE FORM", "Fellow Eye", "FCSUBTH", "Fellow Eye Center Subfield Thickness (um)", 2,
  "DRSSR", "OPHTHALMIC ASSESSMENTS", "SD-OCT CST SINGLE FORM", "Study Eye", "SDRSSR", "Study Eye Diabetic Retinopathy Severity", 3,
  "DRSSR", "OPHTHALMIC ASSESSMENTS", "SD-OCT CST SINGLE FORM", "Fellow Eye", "FDRSSR", "Fellow Eye Diabetic Retinopathy Severity", 4,
  "IOP", "INTRAOCULAR PRESSURE", NA_character_, "Study Eye", "SIOP", "Study Eye IOP (mmHg)", 5,
  "IOP", "INTRAOCULAR PRESSURE", NA_character_, "Fellow Eye", "FIOP", "Fellow Eye IOP (mmHg)", 6
)
# nolint end

# ---- Derivations ----

# Get list of ADSL vars required for derivations
adsl_vars <- exprs(TRTSDT, TRTEDT, TRT01A, TRT01P, STUDYEYE)

adoe_adslvar <- oe %>%
  # Keep only general OE parameters
  filter(
    OETESTCD %in% c("CSUBTH", "DRSSR", "IOP")
  ) %>%
  # Join ADSL with OE (need TRTSDT and STUDYEYE for ADY, AFEYE, and PARAMCD derivation)
  derive_vars_merged(
    dataset_add = adsl,
    new_vars = adsl_vars,
    by_vars = get_admiral_option("subject_keys")
  )

adoe_aval <- adoe_adslvar %>%
  # Calculate AVAL, AVALC, AVALU and DTYPE
  mutate(
    AVAL = OESTRESN,
    AVALC = OESTRESC,
    AVALU = OESTRESU,
    DTYPE = NA_character_
  ) %>%
  # Derive AFEYE needed for PARAMCD derivation
  derive_var_afeye(loc_var = OELOC, lat_var = OELAT, loc_vals = c("EYE", "RETINA"))

adoe_param <- adoe_aval %>%
  # Add PARAM, PARAMCD
  derive_vars_merged(
    dataset_add = param_lookup,
    new_vars = exprs(PARAM, PARAMCD),
    by_vars = exprs(OETESTCD, AFEYE)
  ) %>%
  # Calculate ADT, ADY
  derive_vars_dt(
    new_vars_prefix = "A",
    dtc = OEDTC,
    flag_imputation = "none"
  ) %>%
  derive_vars_dy(reference_date = TRTSDT, source_vars = exprs(ADT))

adoe_visit <- adoe_param %>%
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
  ) %>%
  # Add derived parameter for difference between pre and post dose IOP
  call_derivation(
    derivation = derive_param_computed,
    by_vars = c(get_admiral_option("subject_keys"), !!adsl_vars, exprs(AVISIT, AVISITN, ADT)),
    variable_params = list(
      # Study eye
      params(
        parameters = exprs(
          # Differentiate between pre and post-dose IOP as they are mapped to the same PARAMCD.
          # Users may need to update this code to identify the correct records to use.
          SIOPPRE = PARAMCD == "SIOP" & ATPT == "PRE-DOSE",
          SIOPPOST = PARAMCD == "SIOP" & ATPT == "POST-DOSE"
        ),
        set_values_to = exprs(
          PARAMCD = "SIOPCHG",
          PARAM = "Study Eye IOP Pre to Post Dose Diff (mmHg)",
          PARAMN = 9,
          AVAL = AVAL.SIOPPOST - AVAL.SIOPPRE,
          AVALC = as.character(AVAL),
          BASETYPE = "LAST",
        )
      ),
      # Fellow eye
      params(
        parameters = exprs(
          # Differentiate between pre and post-dose IOP as they are mapped to the same PARAMCD.
          # Users may need to update this code to identify the correct records to use.
          FIOPPRE = PARAMCD == "FIOP" & ATPT == "PRE-DOSE",
          FIOPPOST = PARAMCD == "FIOP" & ATPT == "POST-DOSE"
        ),
        set_values_to = exprs(
          PARAMCD = "FIOPCHG",
          PARAM = "Fellow Eye IOP Pre to Post Dose Diff (mmHg)",
          PARAMN = 10,
          AVAL = AVAL.FIOPPOST - AVAL.FIOPPRE,
          AVALC = as.character(AVAL),
          BASETYPE = "LAST"
        )
      )
    )
  )

# Derive Treatment flags
adoe_trtflag <- adoe_visit %>%
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
adoe_vstflag <- adoe_trtflag %>%
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
    filter = !is.na(AVISITN) & (ONTRTFL == "Y" | ABLFL == "Y") & PARAMCD %in% c("FDRSSR", "SDRSSR")
  )

# Derive baseline information
adoe_change <- adoe_vstflag %>%
  # Calculate BASE (do not derive for IOP change params)
  restrict_derivation(
    derivation = derive_var_base,
    args = params(
      by_vars = c(get_admiral_option("subject_keys"), exprs(PARAMCD, ATPT, BASETYPE)),
      source_var = AVAL,
      new_var = BASE
    ),
    filter = !PARAMCD %in% c("SIOPCHG", "FIOPCHG")
  ) %>%
  # Calculate BASEC (do not derive for IOP change params)
  restrict_derivation(
    derivation = derive_var_base,
    args = params(
      by_vars = c(get_admiral_option("subject_keys"), exprs(PARAMCD, ATPT, BASETYPE)),
      source_var = AVALC,
      new_var = BASEC
    ),
    filter = !PARAMCD %in% c("SIOPCHG", "FIOPCHG")
  ) %>%
  # Calculate CHG (not derived for IOP change params as BASE is NA)
  derive_var_chg() %>%
  # Calculate PCHG (not derived for IOP change params as BASE is NA)
  derive_var_pchg()

# Assign ASEQ
adoe_aseq <- adoe_change %>%
  derive_var_obs_number(
    new_var = ASEQ,
    by_vars = get_admiral_option("subject_keys"),
    order = exprs(PARAMCD, ADT, AVISITN, VISITNUM, ATPTN),
    check_type = "error"
  )

# Add all ADSL variables
adoe_adsl <- adoe_aseq %>%
  derive_vars_merged(
    dataset_add = select(adsl, !!!negate_vars(adsl_vars)),
    by_vars = get_admiral_option("subject_keys")
  )

# Final Steps, Select final variables and Add labels
# This process will be based on your metadata, no example given for this reason
# ...

admiralophtha_adoe <- adoe_adsl

# Save output ----

dir <- tools::R_user_dir("admiralophtha_templates_data", which = "cache")
# Change to whichever directory you want to save the dataset in
if (!file.exists(dir)) {
  # Create the folder
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
}
save(admiralophtha_adoe, file = file.path(dir, "adoe.rda"), compress = "bzip2")
