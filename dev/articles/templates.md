# Explore the admiralophtha ADaM Templates

## Introduction

This page is a catalog of the ADaM templates available through
[admiralophtha](https://pharmaverse.github.io/admiralophtha/). These are
lifted from our GitHub repository. The intention is for this to be a
reference for users, should they wish to peruse the code of a specific
template without visiting the
[admiralophtha](https://pharmaverse.github.io/admiralophtha/)
repository.

As a reminder, you can create a starter script from a template using
[`admiral::use_ad_template()`](https:/pharmaverse.github.io/admiral/v1.5.0/cran-release/reference/use_ad_template.html),
e.g.,

``` r
use_ad_template(
  adam_name = "adsl",
  save_path = "./ad_adoe.R",
  package = "admiralophtha"
)
```

## ADaM templates

ad_adbcva.R

```
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
```

ad_adoe.R

```
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
```

ad_advfq.R

```
# Name: ADVFQ
#
# Label: VFQ Analysis Dataset
#
# Input: adsl, qs
#
# The full, open-source VFQ questionnaire can be accessed here:
# https://www.nei.nih.gov/about/education-and-outreach/outreach-materials/visual-function-questionnaire-25 #nolint

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

# Lookup tables ----

# nolint start

## Original parameters (note PARAM, PARAMCD are identical to QSTEST, QSTESTCD) ----
param_lookup_original <- tribble(
  ~QSTESTCD,  ~PARAM,                                ~PARCAT3,                ~PARCAT4,                              ~PARCAT5,
  "VFQ101",   "Your Overall Health Is",              "general health",        "General Health",                      "Base Item",
  "VFQ102",   "Eyesight Using Both Eyes Is",         "general vision",        "General Vision",                      "Base Item",
  "VFQ103",   "How Often You Worry About Eyesight",  "well-being/distress",   "Vision Specific: Mental Health",      "Base Item",
  "VFQ104",   "How Much Pain in and Around Eyes",    "ocular pain",           "Ocular Pain",                         "Base Item",
  "VFQ105",   "Difficulty Reading Newspapers",       "near vision",           "Near Activities",                     "Base Item",
  "VFQ106",   "Difficulty Doing Work/Hobbies",       "near vision",           "Near Activities",                     "Base Item",
  "VFQ107",   "Difficulty Finding on Crowded Shelf", "near vision",           "Near Activities",                     "Base Item",
  "VFQ108",   "Difficulty Reading Street Signs",     "distance vision",       "Distance Activities",                 "Base Item",
  "VFQ109",   "Difficulty Going Down Step at Night", "distance vision",       "Distance Activities",                 "Base Item",
  "VFQ110",   "Difficulty Noticing Objects to Side", "peripheral vision",     "Peripheral Vision",                   "Base Item",
  "VFQ111",   "Difficulty Seeing How People React",  "social fx",             "Vision Specific: Social Functioning", "Base Item",
  "VFQ112",   "Difficulty Picking Out Own Clothes",  "color vision",          "Color Vision",                        "Base Item",
  "VFQ113",   "Difficulty Visiting With People",     "social fx",             "Vision Specific: Social Functioning", "Base Item",
  "VFQ114",   "Difficulty Going Out to See Movies",  "distance vision",       "Distance Activities",                 "Base Item",
  "VFQ115",   "Are You Currently Driving",           "driving (filter item)", NA_character_,                         "Base Item",
  "VFQ115A",  "Never Driven or Given Up Driving",    "driving (filter item)", NA_character_,                         "Base Item",
  "VFQ115B",  "Main Reason You Gave Up Driving",     "driving (filter item)", NA_character_,                         "Base Item",
  "VFQ115C",  "Difficulty Driving During Daytime",   "driving",               "Driving",                             "Base Item",
  "VFQ116",   "Difficulty Driving at Night",         "driving",               "Driving",                             "Base Item",
  "VFQ116A",  "Driving in Difficult Conditions",     "driving",               "Driving",                             "Base Item",
  "VFQ117",   "Accomplish Less Than You Would Like", "role limitations",      "Vision Specific: Role Difficulties",  "Base Item",
  "VFQ118",   "Limited in How Long You Can Work",    "role limitations",      "Vision Specific: Role Difficulties",  "Base Item",
  "VFQ119",   "Eye Pain Keep From Doing What Like",  "ocular pain",           "Ocular Pain",                         "Base Item",
  "VFQ120",   "I Stay Home Most of the Time",        "dependency",            "Vision Specific: Dependency",         "Base Item",
  "VFQ121",   "I Feel Frustrated a Lot of the Time", "well-being/distress",   "Vision Specific: Mental Health",      "Base Item",
  "VFQ122",   "Much Less Control Over What I Do",    "well-being/distress",   "Vision Specific: Mental Health",      "Base Item",
  "VFQ123",   "Rely Too Much on What Others Tell",   "dependency",            "Vision Specific: Dependency",         "Base Item",
  "VFQ124",   "I Need a Lot of Help From Others",    "dependency",            "Vision Specific: Dependency",         "Base Item",
  "VFQ125",   "Worry I'll Do Embarrassing Things",   "well-being/distress",   "Vision Specific: Mental Health",      "Base Item",
  "VFQ1A01",  "Rate Your Overall Health",            "general health",        "General Health",                      "Optional Item",
  "VFQ1A02",  "Rate Your Eyesight Now",              "general vision",        "General Vision",                      "Optional Item",
  "VFQ1A03",  "Difficulty Reading Small Print",      "near vision",           "Near Activities",                     "Optional Item",
  "VFQ1A04",  "Difficulty Figure Out Bill Accuracy", "near vision",           "Near Activities",                     "Optional Item",
  "VFQ1A05",  "Difficulty Shaving or Styling Hair",  "near vision",           "Near Activities",                     "Optional Item",
  "VFQ1A06",  "Difficulty Recognizing People",       "distance vision",       "Distance Activities",                 "Optional Item",
  "VFQ1A07",  "Difficulty Taking Part in Sports",    "distance vision",       "Distance Activities",                 "Optional Item",
  "VFQ1A08",  "Difficulty Seeing Programs on TV",    "distance vision",       "Distance Activities",                 "Optional Item",
  "VFQ1A09",  "Difficulty Entertaining Friends",     "social fx",             "Vision Specific: Social Functioning", "Optional Item",
  "VFQ1A11A", "Do You Have More Help From Others",   "role limitations",      "Vision Specific: Role Difficulties",  "Optional Item",
  "VFQ1A11B", "Limited in Kinds of Things Can Do",   "role limitations",      "Vision Specific: Role Difficulties",  "Optional Item",
  "VFQ1A12",  "Often Irritable Because Eyesight",    "well-being/distress",   "Vision Specific: Mental Health",      "Optional Item",
  "VFQ1A13",  "I Don't Go Out of My Home Alone",     "dependency",            "Vision Specific: Dependency",         "Optional Item"
) %>%
  mutate(
    PARAMCD = QSTESTCD,
    PARCAT1 = "VFQ-25 INTERVIEWER ADMINISTERED",
    PARCAT2 = "Original Items"
  )

## Transformed parameters ----
param_lookup_transformed <- tribble(
  ~PARAMCD,  ~PARAM,                                              ~PARCAT3,              ~PARCAT4,                              ~PARCAT5,
  "QR01",    "Transformed - Your Overall Health Is",              "general health",      "General Health",                      "Base Item",
  "QR02",    "Transformed - Eyesight Using Both Eyes Is",         "general vision",      "General Vision",                      "Base Item",
  "QR03",    "Transformed - How Often You Worry About Eyesight",  "well-being/distress", "Vision Specific: Mental Health",      "Base Item",
  "QR04",    "Transformed - How Much Pain in and Around Eyes",    "ocular pain",         "Ocular Pain",                         "Base Item",
  "QR05",    "Transformed - Difficulty Reading Newspapers",       "near vision",         "Near Activities",                     "Base Item",
  "QR06",    "Transformed - Difficulty Doing Work/Hobbies",       "near vision",         "Near Activities",                     "Base Item",
  "QR07",    "Transformed - Difficulty Finding on Crowded Shelf", "near vision",         "Near Activities",                     "Base Item",
  "QR08",    "Transformed - Difficulty Reading Street Signs",     "distance vision",     "Distance Activities",                 "Base Item",
  "QR09",    "Transformed - Difficulty Going Down Step at Night", "distance vision",     "Distance Activities",                 "Base Item",
  "QR10",    "Transformed - Difficulty Noticing Objects to Side", "peripheral vision",   "Peripheral Vision",                   "Base Item",
  "QR11",    "Transformed - Difficulty Seeing How People React",  "social fx",           "Vision Specific: Social Functioning", "Base Item",
  "QR12",    "Transformed - Difficulty Picking Out Own Clothes",  "color vision",        "Color Vision",                        "Base Item",
  "QR13",    "Transformed - Difficulty Visiting With People",     "social fx",           "Vision Specific: Social Functioning", "Base Item",
  "QR14",    "Transformed - Difficulty Going Out to See Movies",  "distance vision",     "Distance Activities",                 "Base Item",
  "QR15C",   "Transformed - Main Reason You Gave Up Driving",     "driving",             "Driving",                             "Base Item",
  "QR16",    "Transformed - Difficulty Driving at Night",         "driving",             "Driving",                             "Base Item",
  "QR16A",   "Transformed - Driving in Difficult Conditions",     "driving",             "Driving",                             "Base Item",
  "QR17",    "Transformed - Accomplish Less Than You Would Like", "role limitations",    "Vision Specific: Role Difficulties",  "Base Item",
  "QR18",    "Transformed - Limited in How Long You Can Work",    "role limitations",    "Vision Specific: Role Difficulties",  "Base Item",
  "QR19",    "Transformed - Eye Pain Keep From Doing What Like",  "ocular pain",         "Ocular Pain",                         "Base Item",
  "QR20",    "Transformed - I Stay Home Most of the Time",        "dependency",          "Vision Specific: Dependency",         "Base Item",
  "QR21",    "Transformed - I Feel Frustrated a Lot of the Time", "well-being/distress", "Vision Specific: Mental Health",      "Base Item",
  "QR22",    "Transformed - Much Less Control Over What I Do",    "well-being/distress", "Vision Specific: Mental Health",      "Base Item",
  "QR23",    "Transformed - Rely Too Much on What Others Tell",   "dependency",          "Vision Specific: Dependency",         "Base Item",
  "QR24",    "Transformed - I Need a Lot of Help From Others",    "dependency",          "Vision Specific: Dependency",         "Base Item",
  "QR25",    "Transformed - Worry I'll Do Embarrassing Things",   "well-being/distress", "Vision Specific: Mental Health",      "Base Item",
  "QRA01",   "Transformed - Rate Your Overall Health",            "general health",      "General Health",                      "Optional Item",
  "QRA02",   "Transformed - Rate Your Eyesight Now",              "general vision",      "General Vision",                      "Optional Item",
  "QRA03",   "Transformed - Difficulty Reading Small Print",      "near vision",         "Near Activities",                     "Optional Item",
  "QRA04",   "Transformed - Difficulty Figure Out Bill Accuracy", "near vision",         "Near Activities",                     "Optional Item",
  "QRA05",   "Transformed - Difficulty Shaving or Styling Hair",  "near vision",         "Near Activities",                     "Optional Item",
  "QRA06",   "Transformed - Difficulty Recognizing People",       "distance vision",     "Distance Activities",                 "Optional Item",
  "QRA07",   "Transformed - Difficulty Taking Part in Sports",    "distance vision",     "Distance Activities",                 "Optional Item",
  "QRA08",   "Transformed - Difficulty Seeing Programs on TV",    "distance vision",     "Distance Activities",                 "Optional Item",
  "QRA09",   "Transformed - Difficulty Entertaining Friends",     "social fx",           "Vision Specific: Social Functioning", "Optional Item",
  "QR1A11A", "Transformed - Do You Have More Help From Others",   "role limitations",    "Vision Specific: Role Difficulties",  "Optional Item",
  "QR1A11B", "Transformed - Limited in Kinds of Things Can Do",   "role limitations",    "Vision Specific: Role Difficulties",  "Optional Item",
  "QR1A12",  "Transformed - Often Irritable Because Eyesight",    "well-being/distress", "Vision Specific: Mental Health",      "Optional Item",
  "QR1A13",  "Transformed - I Don't Go Out of My Home Alone",     "dependency",          "Vision Specific: Dependency",         "Optional Item"
) %>%
  mutate(
    PARCAT1 = "VFQ-25 INTERVIEWER ADMINISTERED",
    PARCAT2 = "Transformed - Original Items"
  )

## Composite parameters ----
param_lookup_composite <- tribble(
  ~PARAMCD,   ~PARAM,                                                             ~PARCAT3,      ~PARCAT4,                              ~PARCAT5,
  "QSBGH",    "General Health Score",                                             NA_character_, "General Health",                      "VFQ-25",
  "QSBGV",    "General Vision Score",                                             NA_character_, "General Vision",                      "VFQ-25",
  "QSBNA",    "Near Activities Score",                                            NA_character_, "Near Activities",                     "VFQ-25",
  "QSBDA",    "Distance Activities Score",                                        NA_character_, "Distance Activities",                 "VFQ-25",
  "QSBSF",    "Vision Specific: Social Functioning Score",                        NA_character_, "Vision Specific: Social Functioning", "VFQ-25",
  "QSBCV",    "Color Vision Score",                                               NA_character_, "Color Vision",                        "VFQ-25",
  "QSBPV",    "Peripheral Vision Score",                                          NA_character_, "Peripheral Vision",                   "VFQ-25",
  "QSBDR",    "Driving Score",                                                    NA_character_, "Driving",                             "VFQ-25",
  "QSBRD",    "Vision Specific: Role Difficulties Score",                         NA_character_, "Vision Specific: Role Difficulties",  "VFQ-25",
  "QSBOP",    "Ocular Pain Score",                                                NA_character_, "Ocular Pain",                         "VFQ-25",
  "QSBDP",    "Vision Specific: Dependency Score",                                NA_character_, "Vision Specific: Dependency",         "VFQ-25",
  "QSBMH",    "Vision Specific: Mental Health Score",                             NA_character_, "Vision Specific: Mental Health",      "VFQ-25",
  "QSOGH",    "General Health Score (incl. Optional Items)",                      NA_character_, "General Health",                      "VFQ-39",
  "QSOGV",    "General Vision Score (incl. Optional Items)",                      NA_character_, "General Vision",                      "VFQ-39",
  "QSONA",    "Near Activities Score (incl. Optional Items)",                     NA_character_, "Near Activities",                     "VFQ-39",
  "QSODA",    "Distance Activities Score (incl. Optional Items)",                 NA_character_, "Distance Activities",                 "VFQ-39",
  "QSOSF",    "Vision Specific: Social Functioning Score (incl. Optional Items)", NA_character_, "Vision Specific: Social Functioning", "VFQ-39",
  "QSOCV",    "Color Vision Score (incl. Optional Items)",                        NA_character_, "Color Vision",                        "VFQ-39",
  "QSOPV",    "Peripheral Vision Score (incl. Optional Items)",                   NA_character_, "Peripheral Vision",                   "VFQ-39",
  "QSODR",    "Driving Score (incl. Optional Items)",                             NA_character_, "Driving",                             "VFQ-39",
  "QSORD",    "Vision Specific: Role Difficulties Score (incl. Optional Items)",  NA_character_, "Vision Specific: Role Difficulties",  "VFQ-39",
  "QSOOP",    "Ocular Pain Score (incl. Optional Items)",                         NA_character_, "Ocular Pain",                         "VFQ-39",
  "QSODP",    "Vision Specific: Dependency Score (incl. Optional Items)",         NA_character_, "Vision Specific: Dependency",         "VFQ-39",
  "QSOMH",    "Vision Specific: Mental Health Score (incl. Optional Items)",      NA_character_, "Vision Specific: Mental Health",      "VFQ-39",
  "QBCSCORE", "Composite Score",                                                  NA_character_, "Composite Score",                     "VFQ-25",
  "QOCSCORE", "Composite Score (incl. Optional Items)",                           NA_character_, "Composite Score",                     "VFQ-39"
) %>%
  mutate(
    PARCAT1 = "VFQ-25 INTERVIEWER ADMINISTERED",
    PARCAT2 = "Derived Scale"
  )

# nolint end

# Derivations ----

adsl_vars <- exprs(TRTSDT, TRTEDT, TRT01A, TRT01P)

advfq_dtdy <- qs %>%
  ## merge on ADSL vars ----
  derive_vars_merged(
    dataset_add = adsl,
    new_vars = adsl_vars,
    by_vars = get_admiral_option("subject_keys")
  ) %>%
  ## analysis dates ADT, ADY ----
  derive_vars_dt(
    new_vars_prefix = "A",
    dtc = QSDTC
  ) %>%
  derive_vars_dy(
    reference_date = TRTSDT,
    source_vars = exprs(ADT)
  )

advfq_aval <- advfq_dtdy %>%
  ## Add PARAMCD for original parameters only - PARCATx and PARAM will be added later ----
  derive_vars_merged_lookup(
    dataset_add = param_lookup_original,
    new_vars = exprs(PARAMCD),
    by_vars = exprs(QSTESTCD)
  ) %>%
  ## Calculate AVAL and AVALC and derive BASETYPE ----
  mutate(
    AVAL = QSSTRESN,
    AVALC = QSORRES,
    BASETYPE = "LAST PERIOD 01"
  )

# Get visit info ----
# See also the "Visit and Period Variables" vignette
# (https://pharmaverse.github.io/admiral/cran-release/articles/visits_periods.html)
advfq_visit <- advfq_aval %>%
  # Derive Timing
  mutate(
    AVISIT = case_when(
      !is.na(VISIT) ~ str_to_title(VISIT),
      TRUE ~ NA_character_
    ),
    AVISITN = case_when(
      AVISIT == "Baseline" ~ 1,
      AVISIT == "Week 12" ~ 12,
      AVISIT == "Week 24" ~ 24,
      TRUE ~ NA
    ),
  )

# Derive transformed derived parameters ----

## Divide parameters into groups based on what transformation will be required ----
# Note: 15C treated separately (see below)
range1to5_flip_params <- c(
  "VFQ101", "VFQ103", "VFQ104", "VFQ105", "VFQ106", "VFQ107", "VFQ108",
  "VFQ109", "VFQ110", "VFQ111", "VFQ112", "VFQ113", "VFQ114", "VFQ116",
  "VFQ116A", "VFQ1A03", "VFQ1A04", "VFQ1A05", "VFQ1A06", "VFQ1A07",
  "VFQ1A08", "VFQ1A09"
)

range1to6_flip_params <- c("VFQ102")

range1to5_noflip_params <- c(
  "VFQ117", "VFQ118", "VFQ119", "VFQ120", "VFQ121", "VFQ122", "VFQ123",
  "VFQ124", "VFQ125", "VFQ1A11A", "VFQ1A11B", "VFQ1A12", "VFQ1A13"
)

range0to10_noflip_params <- c("VFQ1A01", "VFQ1A02")

advfq_qr_pre <- advfq_visit %>%
  # Set up temporary flag to be used for QR15C derivation later. The flag identifies
  # visits where QSTESTCD == "VFQ115C" does not exist, for which a different derivation
  # of QR15C is required
  derive_var_merged_exist_flag(
    dataset_add = advfq_aval,
    by_vars = exprs(!!!adsl_vars, ADT, ADY),
    new_var = TEMP_VFQ115C_FL,
    condition = QSTESTCD == "VFQ115C",
    true_value = "Y",
    false_value = "N",
    missing_value = "M"
  )

# Need new block here as TEMP_VFQ115C_FL needs to be part of dataset_add
advfq_qr <- advfq_qr_pre %>%
  call_derivation(
    derivation = derive_extreme_records,
    dataset = .,
    dataset_add = .,
    keep_source_vars = c(
      get_admiral_option("subject_keys"),
      exprs(PARAMCD, AVISIT, AVISITN, ADT, ADY),
      adsl_vars
    ),
    variable_params = list(
      params(
        filter_add = QSTESTCD %in% range1to5_flip_params & !is.na(AVAL),
        set_values_to = exprs(
          AVAL = transform_range(source = AVAL, source_range = c(1, 5), target_range = c(0, 100), flip_direction = TRUE),
          PARAMCD = str_replace(QSTESTCD, "VFQ1", "QR")
        )
      ),
      params(
        filter_add = QSTESTCD %in% range1to6_flip_params & !is.na(AVAL),
        set_values_to = exprs(
          AVAL = transform_range(source = AVAL, source_range = c(1, 6), target_range = c(0, 100), flip_direction = TRUE),
          PARAMCD = str_replace(QSTESTCD, "VFQ1", "QR")
        )
      ),
      params(
        filter_add = QSTESTCD %in% range1to5_noflip_params & !is.na(AVAL),
        set_values_to = exprs(
          AVAL = transform_range(source = AVAL, source_range = c(1, 5), target_range = c(0, 100), flip_direction = FALSE),
          PARAMCD = str_replace(QSTESTCD, "VFQ1", "QR")
        )
      ),
      params(
        filter_add = QSTESTCD %in% range0to10_noflip_params & !is.na(AVAL),
        set_values_to = exprs(
          AVAL = transform_range(source = AVAL, source_range = c(0, 10), target_range = c(0, 100), flip_direction = FALSE),
          PARAMCD = str_replace(QSTESTCD, "VFQ1", "QR")
        )
      ),
      # For QR15C, do it in two parts
      # first in the case where QSTESTCD == "VFQ115C" is present at that visit
      params(
        filter_add = QSTESTCD == "VFQ115C" & !is.na(AVAL),
        set_values_to = exprs(
          AVAL = transform_range(source = AVAL, source_range = c(1, 5), target_range = c(0, 100), flip_direction = TRUE),
          PARAMCD = "QR15C"
        )
      ),
      # second in the case where QSTESTCD == "VFQ115C" is not present at that visit
      params(
        filter_add = TEMP_VFQ115C_FL == "N" & QSTESTCD == "VFQ115B" & AVAL == 1,
        set_values_to = exprs(
          AVAL = 0,
          PARAMCD = "QR15C"
        )
      )
    )
  ) %>%
  select(-TEMP_VFQ115C_FL)

# Add PARAM, PARCAT vars ----
advfq_qr_parcats <- advfq_qr %>%
  derive_vars_merged_lookup(
    dataset_add = rbind(
      param_lookup_original %>% select(-QSTESTCD),
      param_lookup_transformed
    ),
    by_vars = exprs(PARAMCD)
  )

# Derive composite parameters ----

advfq_qsb <- derive_summary_records(
  dataset_add = advfq_qr_parcats,
  filter_add = PARCAT2 == "Transformed - Original Items" & PARCAT5 == "Base Item" & !is.na(AVAL),
  by_vars = c(
    get_admiral_option("subject_keys"),
    exprs(!!!adsl_vars, AVISIT, AVISITN, ADT, ADY, PARCAT4)
  ),
  set_values_to = exprs(AVAL = mean(AVAL))
) %>%
  derive_vars_merged_lookup(
    dataset_add = filter(param_lookup_composite, str_starts(PARAMCD, "QSB")),
    new_vars = exprs(PARAMCD, PARAM, PARCAT1, PARCAT2, PARCAT3, PARCAT5),
    by_vars = exprs(PARCAT4)
  )

advfq_qso <- derive_summary_records(
  dataset_add = advfq_qr_parcats,
  filter_add = PARCAT2 == "Transformed - Original Items" & !is.na(AVAL),
  by_vars = c(
    get_admiral_option("subject_keys"),
    exprs(!!!adsl_vars, AVISIT, AVISITN, ADT, ADY, PARCAT4)
  ),
  set_values_to = exprs(AVAL = mean(AVAL))
) %>%
  derive_vars_merged_lookup(
    dataset_add = filter(param_lookup_composite, str_starts(PARAMCD, "QSO")),
    new_vars = exprs(PARAMCD, PARAM, PARCAT1, PARCAT2, PARCAT3, PARCAT5),
    by_vars = exprs(PARCAT4)
  )

advfq_qs1 <- bind_rows(advfq_qr_parcats, advfq_qsb, advfq_qso)

# Derive score parameters ----
advfq_qs2 <- advfq_qs1 %>%
  call_derivation(
    derivation = derive_summary_records,
    dataset_add = advfq_qs1,
    by_vars = c(
      get_admiral_option("subject_keys"),
      exprs(!!!adsl_vars, AVISIT, AVISITN, ADT, ADY)
    ),
    variable_params = list(
      params(
        # Use base items only
        filter_add = PARCAT5 == "VFQ-25" & str_sub(PARAMCD, 1, 3) == "QSB" & PARCAT4 != "General Health" & !is.na(AVAL),
        set_values_to = exprs(
          AVAL = mean(AVAL),
          PARAMCD = "QBCSCORE"
        )
      ),
      params(
        # Use optional items only
        filter_add = PARCAT5 == "VFQ-39" & str_sub(PARAMCD, 1, 3) == "QSO" & PARCAT4 != "General Health" & !is.na(AVAL),
        set_values_to = exprs(
          AVAL = mean(AVAL),
          PARAMCD = "QOCSCORE"
        )
      )
    )
  )

# Map PARAM, PARCAT1 through 5 -----
advfq_qs2a <- advfq_qs2 %>%
  filter(str_detect(PARAMCD, "SCORE")) %>%
  select(-PARAM, -starts_with("PARCAT")) %>%
  derive_vars_merged_lookup(
    dataset_add = param_lookup_composite,
    new_vars = exprs(PARAM, PARCAT1, PARCAT2, PARCAT3, PARCAT4, PARCAT5),
    by_vars = exprs(PARAMCD)
  ) %>%
  rbind(advfq_qs2 %>% filter(!str_detect(PARAMCD, "SCORE")))

advfq_ontrt <- advfq_qs2a %>%
  # Calculate ONTRTFL ----
  derive_var_ontrtfl(
    start_date = ADT,
    ref_start_date = TRTSDT,
    ref_end_date = TRTEDT,
    filter_pre_timepoint = AVISIT == "Baseline"
  )

# Derive baseline flags ----
advfq_blfl <- advfq_ontrt %>%
  ## Calculate ABLFL ----
  restrict_derivation(
    derivation = derive_var_extreme_flag,
    args = params(
      by_vars = c(get_admiral_option("subject_keys"), exprs(PARAMCD)),
      order = exprs(ADT, AVISITN, QSSEQ),
      new_var = ABLFL,
      mode = "last"
    ),
    filter = (!is.na(AVAL) & ADT <= TRTSDT)
  )

# Derive baseline information ----
advfq_change <- advfq_blfl %>%
  ## Calculate BASE ----
  derive_var_base(
    by_vars = c(get_admiral_option("subject_keys"), exprs(PARAMCD)),
    source_var = AVAL,
    new_var = BASE
  ) %>%
  ## Calculate CHG ----
  restrict_derivation(
    derivation = derive_var_chg,
    filter = AVISITN > 1
  ) %>%
  ## Calculate PCHG ----
  restrict_derivation(
    derivation = derive_var_pchg,
    filter = AVISITN > 1
  )

## ANL01FL: Flag last result within an AVISIT for post-baseline records ----
advfq_anlflag <- advfq_change %>%
  restrict_derivation(
    derivation = derive_var_extreme_flag,
    args = params(
      new_var = ANL01FL,
      by_vars = c(get_admiral_option("subject_keys"), exprs(PARAMCD, AVISIT)),
      order = exprs(ADT, AVAL),
      mode = "last"
    ),
    filter = !is.na(AVISITN) & ONTRTFL == "Y"
  )

# Get ASEQ and PARAM  ----
advfq_aseq <- advfq_anlflag %>%
  ## Calculate ASEQ ----
  derive_var_obs_number(
    new_var = ASEQ,
    by_vars = get_admiral_option("subject_keys"),
    order = exprs(PARAMCD, ADT, AVISITN),
    check_type = "error"
  )

## Add all remaining ADSL variables ----
advfq_adsl <- advfq_aseq %>%
  derive_vars_merged(
    dataset_add = select(adsl, !!!negate_vars(adsl_vars)),
    by_vars = get_admiral_option("subject_keys")
  )

# Final Steps, Select final variables and Add labels
# This process will be based on your metadata, no example given for this reason
# ...

admiralophtha_advfq <- advfq_adsl

# ---- Save output ----

# Save output ----

dir <- tools::R_user_dir("admiralophtha_templates_data", which = "cache")
# Change to whichever directory you want to save the dataset in
if (!file.exists(dir)) {
  # Create the folder
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
}
save(admiralophtha_advfq, file = file.path(dir, "admiralophtha_advfq.rda"), compress = "bzip2")
```
