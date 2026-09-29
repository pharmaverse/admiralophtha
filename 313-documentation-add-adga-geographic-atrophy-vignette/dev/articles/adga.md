# Creating ADGA

## Introduction

This article describes creating an ADGA ADaM dataset containing
Geographic Atrophy (GA) data for ophthalmology endpoints. These
endpoints are derived from Ophthalmic Examination (OE) records and
include both observed and derived measurements for Geographic Atrophy.
It is to be used in conjunction with the article on [creating a BDS
dataset from
SDTM](https://pharmaverse.github.io/admiral/cran-release/articles/bds_finding.html).
As such, derivations and processes that are not specific to ADGA are
absent, and the user is invited to consult the aforementioned article
for guidance.

**Note**: *All examples assume CDISC SDTM and/or ADaM format as input
unless otherwise specified.*

### Dataset Contents

As the name ADGA implies,
[admiralophtha](https://pharmaverse.github.io/admiralophtha/) suggests
to populate ADGA solely with GA records from the OE SDTM.

### Required Packages

The examples of this vignette require the following packages.

``` r
library(dplyr)
library(admiral)
library(pharmaversesdtm)
library(admiraldev)
library(admiralophtha)
library(stringr)
```

## Programming Workflow

- [Initial Set Up of ADGA](#setup)
- [Creating Square Root Transformed GA Area measured by FAF derived
  parameter](#sqrt)
- [Assigning `AVISIT/AVISITN`](#avisit)
- [Further Derivations of Standard BDS Variables](#further)
- [Example Script](#example)

### Initial set up of ADGA

As with all BDS ADaM datasets, one should start from the OE SDTM, where
only records related to geographic atrophy are of interest. For the
purposes of the next two sections, we shall be using the
[admiral](https://pharmaverse.github.io/admiral/) OE and ADSL test data.
We will also require a lookup table for the mapping of parameter codes.
An SAREAFAF, FAREAFAF, SGAFOCAL and FGAFOCAL definition expression is
created first - this expression can also be stored within another
(sourced) program.

**Note**: to simulate an ophthalmology study, we add a randomly
generated `STUDYEYE` variable to ADSL, but in practice `STUDYEYE` will
already have been derived using
[`derive_var_studyeye()`](https:/pharmaverse.github.io/admiralophtha/313-documentation-add-adga-geographic-atrophy-vignette/dev/reference/derive_var_studyeye.md).

``` r
data("oe_ophtha")
data("admiral_adsl")

# Add STUDYEYE to ADSL to simulate an ophtha dataset
# Set seed to ensure reproducible STUDYEYE assignment across runs
set.seed(1234)

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
  "AREA", "OPHTHALMIC ASSESSMENTS", NA_character_, "Study Eye", "SAREAFAF", "Study Eye GA Area measured by FAF (mm2)", 1,
  "AREA", "OPHTHALMIC ASSESSMENTS", NA_character_, "Fellow Eye", "FAREAFAF", "Fellow Eye GA Area measured by FAF (mm2)", 2,
  "GAFLOC", "OPHTHALMIC ASSESSMENTS", NA_character_, "Study Eye", "SGAFOCAL", "Study Eye GA Lesion Focality", 3,
  "GAFLOC", "OPHTHALMIC ASSESSMENTS", NA_character_, "Fellow Eye", "FGAFOCAL", "Fellow Eye GA Lesion Focality", 4
)
# nolint end
```

Following this setup, the programmer can start constructing ADGA. The
first step is to subset OE to only GA parameters like “AREA”, “GAFLOC”
and merge with ADSL. This is required for two reasons: firstly,
`STUDYEYE` is crucial in the mapping of `AFEYE` and `PARAMCD`’s.
Secondly, the treatment start date (`TRTSDT`) is also a prerequisite for
the derivation of variables such as Analysis Day (`ADY`).

``` r
# Get list of ADSL vars required for derivations
adsl_vars <- exprs(TRTSDT, TRTEDT, TRT01A, TRT01P, STUDYEYE)

adga <- oe %>%
  # Keep only GA related OE parameters
  filter(
    OETESTCD %in% c("AREA", "GAFLOC")
  ) %>%
  # Join ADSL with OE (need TRTSDT and STUDYEYE for ADY, AFEYE, and PARAMCD derivation)
  derive_vars_merged(
    dataset_add = adsl,
    new_vars = adsl_vars,
    by_vars = get_admiral_option("subject_keys")
  )
```

The next item of business is to derive `AVAL`,`AVALC`, `AVALU`, and
`DTYPE`. In this example, derivation for `AVALC` is trivial, whereas for
lesion focality, `AVAL` is derived using a combination of OE character
standard results and decoded to 1 for S(single), and 2 for
NS(multifocal). `AFEYE` is also created in this step using the function
[`derive_var_afeye()`](https:/pharmaverse.github.io/admiralophtha/313-documentation-add-adga-geographic-atrophy-vignette/dev/reference/derive_var_afeye.md).

``` r
adga <- adga %>%
  # Calculate AVAL, AVALC, AVALU and DTYPE
  mutate(
    AVAL = case_when(
      OETESTCD == "GAFLOC" & OESTRESC == "S" ~ 1,
      OETESTCD == "GAFLOC" & OESTRESC == "NS" ~ 2,
      TRUE ~ OESTRESN
    ),
    AVALC = OESTRESC,
    AVALU = OESTRESU,
    DTYPE = NA_character_
  ) %>%
  # Derive AFEYE needed for PARAMCD derivation
  derive_var_afeye(loc_var = OELOC, lat_var = OELAT, loc_vals = c("EYE", "RETINA"))
```

### Creating Square Root Transformed GA Area measured by FAF derived parameter

Next, `PARAM`, `PARAMCD` and `PARAMN` can be assigned using
[`derive_vars_merged_lookup()`](https:/pharmaverse.github.io/admiral/v1.5.0/cran-release/reference/derive_vars_merged_lookup.html)
from [admiral](https://pharmaverse.github.io/admiral/) and the lookup
table `param_lookup` generated above. Often ADGA datasets contain square
root transformed GA records for FAF with units as mm. This can easily be
achieved as follows using
[`derive_param_computed()`](https:/pharmaverse.github.io/admiral/v1.5.0/cran-release/reference/derive_param_computed.html).
Two separate calls are required due to the parameters being split by
study and fellow eye. Once these extra parameters are added, all the
records that will be in the end dataset are now present, so day/date
variables such as `ADY` and `ADT` can be derived.

``` r
adga <- adga %>%
  # Add PARAM, PARAMCD, PARAMN
  derive_vars_merged_lookup(
    dataset_add = param_lookup,
    new_vars = exprs(PARAM, PARAMCD, PARAMN),
    by_vars = exprs(OETESTCD, AFEYE)
  ) %>%
  # Add derived parameters for Square Root Transformed GA Area measured by FAF
  call_derivation(
    derivation = derive_param_computed,
    by_vars = c(
      get_admiral_option("subject_keys"),
      exprs(VISIT, VISITNUM, OEDY, OEDTC, AFEYE, !!!adsl_vars)
    ),
    variable_params = list(
      # Study eye
      params(
        # Users may need to update this code to identify the correct records to use.
        parameters = exprs(SESQRT = PARAMCD == "SAREAFAF"),
        set_values_to = exprs(
          PARAMCD = "SSQRTFAF",
          PARAM = "Study Eye Square Root Transformed GA Area measured by FAF (mm)",
          PARAMN = 5,
          AVAL = sqrt(AVAL.SESQRT),
          AVALC = as.character(AVAL),
          AVALU = "mm",
          DTYPE = "SQRT"
        )
      ),
      # Fellow eye
      params(
        # Users may need to update this code to identify the correct records to use.
        parameters = exprs(FESQRT = PARAMCD == "FAREAFAF"),
        set_values_to = exprs(
          PARAMCD = "FSQRTFAF",
          PARAM = "Fellow Eye Square Root Transformed GA Area measured by FAF (mm)",
          PARAMN = 6,
          AVAL = sqrt(AVAL.FESQRT),
          AVALC = as.character(AVAL),
          AVALU = "mm",
          DTYPE = "SQRT"
        )
      )
    )
  ) %>%
  # Calculate ADT, ADY
  derive_vars_dt(
    new_vars_prefix = "A",
    dtc = OEDTC,
    flag_imputation = "none"
  ) %>%
  derive_vars_dy(reference_date = TRTSDT, source_vars = exprs(ADT))
#> All `OETESTCD` and `AFEYE` are mapped.
```

Importantly, the above calls to
[`derive_param_computed()`](https:/pharmaverse.github.io/admiral/v1.5.0/cran-release/reference/derive_param_computed.html)
list the SDTM variables `VISIT`, `VISITNUM`, `OEDY` and `OEDTC` as
`by_vars` for the function. This is because they will be necessary to
derive ADaM variables such as `AVISIT` and `ADY` in successive steps.

### Assigning `AVISIT/AVISITN`

Moving forwards, `AVISIT`, `AVISITN` and related timepoint variables can
be derived soon after, though their derivation is generally
study-specific. A simple option is included below; please consult the
[admiral](https://pharmaverse.github.io/admiral/) [BDS findings
vignette](https://pharmaverse.github.io/admiral/cran-release/articles/bds_finding.html#timing)
for a more detailed discussion.

Additionally, it should be noted that for the `SGAFOCAL` and `FGAFOCAL`
parameters, it is generally recommended not to populate `BASE`, `CHG`
and `PCHG` as they contain character result. This can be simply achieved
in one step, as the derivation of
[`derive_var_base()`](https:/pharmaverse.github.io/admiral/v1.5.0/cran-release/reference/derive_var_base.html)
can be placed inside of
[`restrict_derivation()`](https:/pharmaverse.github.io/admiral/v1.5.0/cran-release/reference/restrict_derivation.html)
with a filter added to exclude these parameters. Then, `BASE` will be
set to `NA` for `SGAFOCAL` and `FGAFOCAL`, so later calls to
[`derive_var_chg()`](https:/pharmaverse.github.io/admiral/v1.5.0/cran-release/reference/derive_var_chg.html)
and
[`derive_var_pchg()`](https:/pharmaverse.github.io/admiral/v1.5.0/cran-release/reference/derive_var_pchg.html)
do not need any changes.

``` r
adga <- adga %>%
  # Calculate BASE (do not derive for GA Lesion Focality params)
  restrict_derivation(
    derivation = derive_var_base,
    args = params(
      by_vars = c(get_admiral_option("subject_keys"), exprs(PARAMCD, ATPT)),
      source_var = AVAL,
      new_var = BASE
    ),
    filter = !PARAMCD %in% c("SGAFOCAL", "FGAFOCAL")
  )
```

### Further Derivations of Standard BDS Variables

The user is invited to consult the article on [creating a BDS dataset
from
SDTM](https://pharmaverse.github.io/admiral/cran-release/articles/bds_finding.html)
to learn how to add standard BDS variables to ADGA

### Example Script

| ADaM | Sample Code                                          |
|------|------------------------------------------------------|
| ADGA | `use_ad_template("adga", package = "admiralophtha")` |
