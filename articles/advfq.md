# Creating ADVFQ

## Introduction

This article describes creating an ADVFQ ADaM with Visual Functioning
Questionnaire data for ophthalmology endpoints. It is to be used in
conjunction with the article on [creating a BDS dataset from
SDTM](https://pharmaverse.github.io/admiral/articles/bds_finding.html).
As such, derivations and processes that are not specific to ADVFQ are
mostly absent, and the user is invited to consult the aforementioned
article for guidance.

The full, open-source VFQ questionnaire can be accessed
[here](https://www.nei.nih.gov/about/education-and-outreach/outreach-materials/visual-function-questionnaire-25).

**Note**: *All examples assume CDISC SDTM and/or ADaM format as input
unless otherwise specified. Also, some of the example datasets in this
vignette contain more records than are displayed by default, but the
number of displayed records can be expanded using the selectors at the
bottom.*

### Dataset Contents

[admiralophtha](https://pharmaverse.github.io/admiralophtha/) suggests
to populate ADVFQ solely with VFQ-related records. Any other
questionnaire data should be placed in separate datasets (e.g. ADQS).

The records in ADVFQ can be categorized in four groups:

1.  The **original**/**raw** records coming from the VFQ itself. These
    include both the Base items in the standard VFQ-25 and the Optional
    items which can be added to form the VFQ-39. Importantly, not all of
    the items are measured on the same scale.
2.  The **transformed** records, which are in a one-to-one
    correspondence with the original records and serve to recode the
    latter on the same 0 - 100 scale.
3.  The **composite scores by category**, which are means of all the
    transformed records from within a category, e.g. “Near activities
    score”. These composite scores can be calculated including or
    excluding the Optional items.
4.  The **overall composite scores**, which are means of the composite
    scores, again including or excluding the Optional items.

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

- [Reading In Data and Setting Up Lookup Tables](#setup_lookup)
- [Initial Set Up and Mapping the Raw Records](#mapping_raw)
- [Deriving the Transformed Parameters](#deriving_transformed)
- [Deriving the Composite Parameters](#deriving_composite)
- [Further Derivations of Standard BDS Variables](#further)
- [Example Script](#example)

### Reading In Data and Setting Up Lookup Tables

To start, all datasets needed for the creation of the VFQ analysis
dataset should be read into the environment. For the purpose of
demonstration we shall use the
[pharmaversesdtm](https://pharmaverse.github.io/pharmaversesdtm/)
`qs_ophtha` and the [admiral](https://pharmaverse.github.io/admiral/)
ADSL test datasets. Note that the former only contains VFQ records.

``` r
data("admiral_adsl")
data("qs_ophtha")

adsl <- admiral_adsl
qs <- qs_ophtha
```

Next, it will prove useful to set up lookup tables ahead of time for the
`PARAM`/`PARAMCD` and `PARCATy` variables for the original, transformed
and composite parameters. This is so that when the latter two are
derived later in the script, we can simply assign `PARAMCD` (or one of
the `PARCATy`s) and then perform a merge with the lookup tables to
associate to them the remaining variables as well. **Please note that
the mappings described through these lookup tables may vary from company
to company - this is just what
[admiralophtha](https://pharmaverse.github.io/admiralophtha/)
suggests.**

For convenience, we suggest setting up three separate lookup tables. You
can peruse how the tables are structured below - for the full set up
code, please visit the
[ad_advfq.R](https://github.com/pharmaverse/admiralophtha/blob/main/inst/templates/ad_advfq.R)
template. There is a special importance for the contents of `PARCAT4`
since this determines the categories which are then averaged within the
[composite parameters](#deriving_composite). You can differentiate the
Base Items from the Optional ones using `PARCAT5`, and the original,
transformed and composite parameters using `PARCAT2`.

##### Original Items (`param_lookup_original`)

##### Transformed Records (`param_lookup_transformed`)

##### Composite Records (`param_lookup_composite`)

### Initial Set Up and Mapping the Raw Records

We can now start setting up ADVFQ by taking `qs` and merging on some
ADSL variables which are needed for BDS derivations later down the line.
Note that there is no need to merge on the whole ADSL dataset
immediately as in so doing we would be needlessly increasing the size of
the working dataset; the rest of the variables can be merged on at the
end.

``` r
adsl_vars <- exprs(TRTSDT, TRTEDT, TRT01A, TRT01P)

advfq <- qs %>%
  derive_vars_merged(
    dataset_add = adsl,
    new_vars = adsl_vars,
    by_vars = get_admiral_option("subject_keys")
  )
```

Now we can derive the analysis date (`ADT`) and analysis relative day
(`ADY`) variables. These derivations are study-specific and so the ones
below are just examples - the user is again invited to consult the
vignette on [creating a BDS dataset from
SDTM](https://pharmaverse.github.io/admiral/articles/bds_finding.html)
for details on this topic.

``` r
advfq <- advfq %>%
  derive_vars_dt(
    new_vars_prefix = "A",
    dtc = QSDTC
  ) %>%
  derive_vars_dy(
    reference_date = TRTSDT,
    source_vars = exprs(ADT)
  )
```

Next, we can assign `PARAMCD` for the original parameters by merging
with the `param_lookup_original` table we set up earlier. Using
[`derive_vars_merged_lookup()`](https:/pharmaverse.github.io/admiral/v1.4.0/cran-release/reference/derive_vars_merged_lookup.html)
allows us to get console-level feedback that all the `QSTESTCD`s have
been mapped. We only add `PARAMCD` for now, and will derive `PARCATy`
and `PARAM` later - again to avoid carrying forward too many variables.

We can also derive `AVAL`, `AVALC` and `BASETYPE` for the original
records with a simple
[`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html)
statement, and then `AVISIT` and `AVISITN` with study-specific logic.

``` r
advfq <- advfq %>%
  ## Add PARAMCD for original parameters only - PARCATy and PARAM will be added later
  derive_vars_merged_lookup(
    dataset_add = param_lookup_original,
    new_vars = exprs(PARAMCD),
    by_vars = exprs(QSTESTCD)
  ) %>%
  mutate(
    AVAL = QSSTRESN,
    AVALC = QSORRES,
    BASETYPE = "LAST PERIOD 01"
  ) %>%
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
#> All `QSTESTCD` are mapped.
```

Here’s what the data for the “Near Activities” and “Distance Activities”
questions looks like for one patient’s first two visits:

### Deriving the Transformed Parameters

Now we are ready to derive the transformed parameters. Excluding 15C
(see later down this section), all of these are derived by re-scaling a
single original record. As such, the prototypical code which can be used
to derive them is a call to
[`derive_extreme_records()`](https:/pharmaverse.github.io/admiral/v1.4.0/cran-release/reference/derive_extreme_records.html)
which is structured as follows:

``` r
derive_extreme_records(
  dataset = advfq,
  dataset_add = advfq,
  filter_add = QSTESTCD == "VFQ1xx" & !is.na(AVAL),
  set_values_to = exprs(
    AVAL = transform_range(
      source = AVAL,
      source_range = c(1, 5), # or some other range, e.g. c(1, 6), depending on the parameter
      target_range = c(0, 100),
      flip_direction = TRUE # or FALSE, depending on the parameter
    ),
    PARAMCD = "QRxx"
  )
)
```

The function
[`transform_range()`](https:/pharmaverse.github.io/admiral/v1.4.0/cran-release/reference/transform_range.html)
is a helper function from
[admiral](https://pharmaverse.github.io/admiral/) which performs the
re-scaling. You will need to specify the `source_range` (i.e. the range
of possible values for the original record) and whether or not to
`flip_direction` (i.e. whether higher values of the original record
correspond to better or worse outcomes). Note that both the
`source_range` and `flip_direction` *will* change across parameters -
for instance, the source range is `c(1, 5)` for `PARAMCD == "VFQ101"`
but `c(1, 6)` for `PARAMCD == "VFQ102"`. As such it is useful to group
all parameters (excluding 15C, for which a different approach will be
needed) based on which transformation they require; in so doing the
transformations for each group can be done together.

``` r
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
```

For question 15C we have to be a little more careful as the derivation
depends on whether or not question 15C was asked at that visit. If it
was, then we can derive the transformed record as normal. However, if it
wasn’t, then we have to check the response to question 15B - if the
response to 15B indicates that the patient has never driven or given up
driving (i.e. `QSSTRESN == 1`), then we set the transformed record to 0;
otherwise, we do not derive a transformed record for that visit. To do
this, we can set up a temporary flag variable using
[`derive_var_merged_exist_flag()`](https:/pharmaverse.github.io/admiral/v1.4.0/cran-release/reference/derive_var_merged_exist_flag.html)
to identify visits where question 15C was not asked, and then use that
flag in the derivation of the transformed record for 15C.

``` r
advfq <- advfq %>%
  derive_var_merged_exist_flag(
    dataset_add = advfq,
    by_vars = exprs(!!!adsl_vars, ADT, ADY),
    new_var = TEMP_VFQ115C_FL,
    condition = QSTESTCD == "VFQ115C",
    true_value = "Y",
    false_value = "N",
    missing_value = "M"
  )
```

We can then derive the transformed records, including the special
handling for 15C, in a single call to
[`call_derivation()`](https:/pharmaverse.github.io/admiral/v1.4.0/cran-release/reference/call_derivation.html),
since each call to
[`derive_extreme_records()`](https:/pharmaverse.github.io/admiral/v1.4.0/cran-release/reference/derive_extreme_records.html)
contains the same assignment of `dataset`, `dataset_add` and
`keep_source_vars`, then only differs in the `filter_add` and
`set_values_to` arguments. Each list passed to `variable_params`
performs the transformation for one of the groups of parameters set up
above, including dynamical generation of the `PARAMCD`, though 15C is
done separately. Note that we set `keep_source_vars = adsl_vars` to
ensure SDTM records do not get populated for derived parameters.

``` r
advfq <- advfq %>%
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
          AVAL = transform_range(
            source = AVAL,
            source_range = c(1, 5),
            target_range = c(0, 100),
            flip_direction = TRUE
          ),
          PARAMCD = str_replace(QSTESTCD, "VFQ1", "QR")
        )
      ),
      params(
        filter_add = QSTESTCD %in% range1to6_flip_params & !is.na(AVAL),
        set_values_to = exprs(
          AVAL = transform_range(
            source = AVAL,
            source_range = c(1, 6),
            target_range = c(0, 100),
            flip_direction = TRUE
          ),
          PARAMCD = str_replace(QSTESTCD, "VFQ1", "QR")
        )
      ),
      params(
        filter_add = QSTESTCD %in% range1to5_noflip_params & !is.na(AVAL),
        set_values_to = exprs(
          AVAL = transform_range(
            source = AVAL,
            source_range = c(1, 5),
            target_range = c(0, 100),
            flip_direction = FALSE
          ),
          PARAMCD = str_replace(QSTESTCD, "VFQ1", "QR")
        )
      ),
      params(
        filter_add = QSTESTCD %in% range0to10_noflip_params & !is.na(AVAL),
        set_values_to = exprs(
          AVAL = transform_range(
            source = AVAL,
            source_range = c(0, 10),
            target_range = c(0, 100),
            flip_direction = FALSE
          ),
          PARAMCD = str_replace(QSTESTCD, "VFQ1", "QR")
        )
      ),
      # For QR15C, do it in two parts
      # first in the case where QSTESTCD == "VFQ115C" is present at that visit
      params(
        filter_add = QSTESTCD == "VFQ115C" & !is.na(AVAL),
        set_values_to = exprs(
          AVAL = transform_range(
            source = AVAL,
            source_range = c(1, 5),
            target_range = c(0, 100),
            flip_direction = TRUE
          ),
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
```

We can then add the `PARAM` and `PARCATy` variables for both the
original and transformed records by merging with the relevant lookup
tables.

``` r
advfq <- advfq %>%
  derive_vars_merged_lookup(
    dataset_add = rbind(
      param_lookup_original %>% select(-QSTESTCD),
      param_lookup_transformed
    ),
    by_vars = exprs(PARAMCD)
  )
#> All `PARAMCD` are mapped.
```

Here’s what some of the transformed parameters and original records look
like alongside each other for one patient’s first two visits:

### Deriving the Composite Parameters

#### Composite Scores by Category

With the now-derived transformed parameters (identifiable through
`PARCAT2 == "Transformed - Original Items"`), we have every question
measured on the same scale and can derive the composite parameters.
These are essentially just means across categories of questions, with
the category being determined by the contents of `PARCAT4`. The VFQ
guidelines dictate that for each category, two different composite
parameters should be derived: one including just the Base items of the
questionnaire (`PARCAT5 == "Base Item"`) and the other one also
including any Optional items. As such, below we derive the composite
parameters in two stages, first constructing `advfq_qsb` for the Base
item-only composite means, and then `advfq_qso` for the means including
all items.

Note that the `dataset` argument is not passed to
[`derive_summary_records()`](https:/pharmaverse.github.io/admiral/v1.4.0/cran-release/reference/derive_summary_records.html),
meaning the output datasets contain only the new composite parameters.
Also, this time we use `PARCAT4` as a by-variable, meaning that the new
composite scores are assigned the same value of `PARCAT4`
(e.g. “Distance Activities”) as the records that were used to constitute
them. Then, we can then use
[`derive_vars_merged_lookup()`](https:/pharmaverse.github.io/admiral/v1.4.0/cran-release/reference/derive_vars_merged_lookup.html)
to add on the `PARCATy` (excluding `PARCAT4`) and `PARAM`/`PARAMCD`
variables for these new records. At the end, we append the new records
to the existing `advfq` using
[`bind_rows()`](https://dplyr.tidyverse.org/reference/bind_rows.html).

``` r
advfq_qsb <- derive_summary_records(
  dataset_add = advfq,
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
#> All `PARCAT4` are mapped.

advfq_qso <- derive_summary_records(
  dataset_add = advfq,
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
#> All `PARCAT4` are mapped.

advfq <- bind_rows(advfq, advfq_qsb, advfq_qso)
```

Here’s what the Base item composite scores by category look like for the
“Near Activities” and “Distance Activities” categories for one patient’s
first two visits:

#### Overall Composite Scores

Finally, for the overall composite scores, we take all the newly-derived
composite parameters, excluding “General Health”, and create:

- An averaged record (`PARAMCD == "QBCSCORE"`) using the composite
  scores that were calculated with Base items only;
- An averaged record (`PARAMCD == "QOCSCORE"`) using the composite
  scores that were calculated with Base and Optional items.

As was done for the [transformed parameters](#deriving_transformed), we
do this in a single call to
[`call_derivation()`](https:/pharmaverse.github.io/admiral/v1.4.0/cran-release/reference/call_derivation.html),
since the only difference between the two derivations is the
`filter_add` and `set_values_to` arguments.

``` r
advfq <- advfq %>%
  call_derivation(
    derivation = derive_summary_records,
    dataset_add = advfq,
    by_vars = c(
      get_admiral_option("subject_keys"),
      exprs(!!!adsl_vars, AVISIT, AVISITN, ADT, ADY)
    ),
    variable_params = list(
      params(
        # Use Base Items only
        filter_add = PARCAT5 == "VFQ-25" & str_sub(PARAMCD, 1, 3) == "QSB" &
          PARCAT4 != "General Health" & !is.na(AVAL),
        set_values_to = exprs(
          AVAL = mean(AVAL),
          PARAMCD = "QBCSCORE"
        )
      ),
      params(
        # Use optional items items only
        filter_add = PARCAT5 == "VFQ-39" & str_sub(PARAMCD, 1, 3) == "QSO" &
          PARCAT4 != "General Health" & !is.na(AVAL),
        set_values_to = exprs(
          AVAL = mean(AVAL),
          PARAMCD = "QOCSCORE"
        )
      )
    )
  )
```

We then assign `PARAM`/`PARAMCD` and `PARCATy` for these new overall
composite records by merging with the relevant lookup table, and append
them to `advfq`.

``` r
advfq <- advfq %>%
  filter(str_detect(PARAMCD, "SCORE")) %>%
  select(-PARAM, -starts_with("PARCAT")) %>%
  derive_vars_merged_lookup(
    dataset_add = param_lookup_composite,
    new_vars = exprs(PARAM, PARCAT1, PARCAT2, PARCAT3, PARCAT4, PARCAT5),
    by_vars = exprs(PARAMCD)
  ) %>%
  rbind(advfq %>% filter(!str_detect(PARAMCD, "SCORE")))
#> All `PARAMCD` are mapped.
```

Here’s what the overall composite records using the Base and Optional
items for one patient’s baseline visit:

### Further Derivations of Standard BDS Variables

The user is invited to consult the article on [creating a BDS dataset
from
SDTM](https://pharmaverse.github.io/admiral/articles/bds_finding.html)
to learn how to add standard BDS variables to ADVFQ.

### Example Script

| ADaM  | Sample Code                                                                                    |
|-------|------------------------------------------------------------------------------------------------|
| ADVFQ | [ad_advfq.R](https://github.com/pharmaverse/admiralophtha/blob/main/inst/templates/ad_advfq.R) |
