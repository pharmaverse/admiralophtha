# Adds `CRITx`/`CRITxFL` pairs to BCVA dataset

**\[deprecated\]** The `derive_var_bcvacritxfl()` function has been
deprecated in favor of
[`admiral::derive_vars_crit_flag()`](https:/pharmaverse.github.io/admiral/v1.3.1/cran-release/reference/derive_vars_crit_flag.html) -
please see the [criterion flag section of the ADBCVA
vignette](https://pharmaverse.github.io/admiralophtha/articles/adbcva.html#critflags)
for more details.

Adds a criterion variables `CRITx` and their corresponding flags
`CRITxFL` to a dataset containing BCVA records

## Usage

``` r
derive_var_bcvacritxfl(
  dataset,
  crit_var,
  bcva_ranges = NULL,
  bcva_uplims = NULL,
  bcva_lowlims = NULL,
  additional_text = "",
  critxfl_index = NULL
)
```

## Arguments

- dataset:

  Input dataset containing BCVA data (usually ADBCVA).

  Permitted values

  :   a dataset, i.e., a `data.frame` or tibble

  Default value

  :   none

- crit_var:

  Variable with respect to which `CRITx`/`CRITxFL` are derived (usually
  `CHG` or `AVAL`).

  Permitted values

  :   an unquoted symbol, e.g., `AVAL`

  Default value

  :   none

- bcva_ranges:

  List of numeric vectors. For each vector `c(a,b)` in `bcva_ranges`, a
  pair of variables `CRITx`, `CRITxFL` is created with the condition:
  `a <= crit_var <= b`. If criterion flags of that type are not
  required, then leave as `NULL`.

  Permitted values

  :   a list containing one or more numeric vectors, each of length two.
      E.g. `list(c(1, 2), c(3, 4)`

  Default value

  :   `NULL`

- bcva_uplims:

  List containing one or more numeric elements. For each element a in
  `bcva_uplims`, a pair of variables `CRITx`, `CRITxFL` is created with
  the condition: `crit_var <= a`. If criterion flags of that type are
  not required, then leave as `NULL`.

  Permitted values

  :   a list containing one or more numeric scalars. E.g. `list(2, -4)`

  Default value

  :   `NULL`

- bcva_lowlims:

  List containing one or more numeric elements. For each element b in
  `bcva_lowlims`, a pair of variables `CRITx`, `CRITxFL` is created with
  the condition: `crit_var >= b`. If criterion flags of that type are
  not required, then leave as `NULL`.

  Permitted values

  :   a list containing one or more numeric scalars. E.g. `list(2, -4)`

  Default value

  :   `NULL`

- additional_text:

  string containing additional text to append to `CRITx`.

  Permitted values

  :   a character scalar, i.e., a character vector of length one

  Default value

  :   `""`

- critxfl_index:

  positive integer detailing the first value of x to use in `CRITxFL`.
  If not supplied, the function takes the first available value of x,
  counting up from x = 1.

  Permitted values

  :   a positive integer, e.g. `2` or `5`

  Default value

  :   `NULL`

## Value

The input BCVA dataset with additional column pairs`CRITx`, `CRITxFL`.

## Details

This function works by calling `derive_var_bcvacritxfl()` once for each
of the elements in `bcva_ranges`, `bcva_uplims` and `bcva_lowlims`.
NOTE: if `crit_var` is equal to `NA`, then the resulting criterion flag
is also marked as `NA`.

## See also

Other deprecated:
[`derive_var_bcvacritxfl_util()`](https://pharmaverse.github.io/admiralophtha/dev/reference/derive_var_bcvacritxfl_util.md)

## Author

Edoardo Mancini

## Examples

``` r
library(tibble)
library(admiral)
library(admiraldev)

adbcva1 <- tribble(
  ~STUDYID, ~USUBJID, ~AVISIT, ~BASETYPE, ~PARAMCD, ~CHG,
  "XXX001", "P01", "BASELINE", "LAST", "SBCVA", 0,
  "XXX001", "P01", "WEEK 2", "LAST", "FBCVA", 2,
  "XXX001", "P02", "BASELINE", "LAST", "SBCVA", -13,
  "XXX001", "P02", "WEEK 2", "LAST", "FBCVA", 5,
  "XXX001", "P03", "BASELINE", "LAST", "SBCVA", NA,
  "XXX001", "P03", "WEEK 2", "LAST", "FBCVA", 17
)

derive_var_bcvacritxfl(
  dataset = adbcva1,
  crit_var = exprs(CHG),
  bcva_ranges = list(c(0, 5), c(-5, -1), c(10, 15)),
  bcva_uplims = list(5, 10),
  bcva_lowlims = list(8),
  additional_text = ""
)
#> `derive_var_bcvacritxfl()` was deprecated in admiralophtha 1.4.0.
#> ℹ Please use `admiral::derive_vars_crit_flag()` instead.
#> ℹ See admiralophtha's guidance on creating BCVA criterion flags here:
#>   https://pharmaverse.github.io/admiralophtha/articles/adbcva.html#critflags
#> ✖ This message will turn into a warning with release of admiralophtha 1.5.0.
#> # A tibble: 6 × 18
#>   STUDYID USUBJID AVISIT   BASETYPE PARAMCD   CHG CRIT1    CRIT1FL CRIT2 CRIT2FL
#>   <chr>   <chr>   <chr>    <chr>    <chr>   <dbl> <chr>    <chr>   <chr> <chr>  
#> 1 XXX001  P01     BASELINE LAST     SBCVA       0 0 <= CH… Y       -5 <… N      
#> 2 XXX001  P01     WEEK 2   LAST     FBCVA       2 0 <= CH… Y       -5 <… N      
#> 3 XXX001  P02     BASELINE LAST     SBCVA     -13 0 <= CH… N       -5 <… N      
#> 4 XXX001  P02     WEEK 2   LAST     FBCVA       5 0 <= CH… Y       -5 <… N      
#> 5 XXX001  P03     BASELINE LAST     SBCVA      NA 0 <= CH… NA      -5 <… NA     
#> 6 XXX001  P03     WEEK 2   LAST     FBCVA      17 0 <= CH… N       -5 <… N      
#> # ℹ 8 more variables: CRIT3 <chr>, CRIT3FL <chr>, CRIT4 <chr>, CRIT4FL <chr>,
#> #   CRIT5 <chr>, CRIT5FL <chr>, CRIT6 <chr>, CRIT6FL <chr>

adbcva2 <- tribble(
  ~STUDYID, ~USUBJID, ~AVISIT, ~BASETYPE, ~PARAMCD, ~AVAL, ~CHG,
  "XXX001", "P01", "BASELINE", "LAST", "SBCVA", 4, NA,
  "XXX001", "P01", "BASELINE", "LAST", "SBCVA", 6, NA,
  "XXX001", "P01", "AVERAGE BASELINE", "AVERAGE", "SBCVA", 5, NA,
  "XXX001", "P01", "WEEK 2", "LAST", "SBCVA", -3, NA,
  "XXX001", "P01", "WEEK 4", "LAST", "SBCVA", -10, NA,
  "XXX001", "P01", "WEEK 6", "LAST", "SBCVA", 12, NA,
  "XXX001", "P01", "WEEK 2", "AVERAGE", "SBCVA", -2, -7,
  "XXX001", "P01", "WEEK 4", "AVERAGE", "SBCVA", 6, 1,
  "XXX001", "P01", "WEEK 6", "AVERAGE", "SBCVA", 3, -2
)

restrict_derivation(
  adbcva2,
  derivation = derive_var_bcvacritxfl,
  args = params(
    crit_var = exprs(CHG),
    bcva_ranges = list(c(0, 5), c(-10, 0)),
    bcva_lowlims = list(5),
    additional_text = " (AVERAGE)"
  ),
  filter = PARAMCD %in% c("SBCVA", "FBCVA") & BASETYPE == "AVERAGE"
)
#> # A tibble: 9 × 13
#>   STUDYID USUBJID AVISIT        BASETYPE PARAMCD  AVAL   CHG CRIT1 CRIT1FL CRIT2
#>   <chr>   <chr>   <chr>         <chr>    <chr>   <dbl> <dbl> <chr> <chr>   <chr>
#> 1 XXX001  P01     AVERAGE BASE… AVERAGE  SBCVA       5    NA 0 <=… NA      -10 …
#> 2 XXX001  P01     WEEK 2        AVERAGE  SBCVA      -2    -7 0 <=… N       -10 …
#> 3 XXX001  P01     WEEK 4        AVERAGE  SBCVA       6     1 0 <=… Y       -10 …
#> 4 XXX001  P01     WEEK 6        AVERAGE  SBCVA       3    -2 0 <=… N       -10 …
#> 5 XXX001  P01     BASELINE      LAST     SBCVA       4    NA NA    NA      NA   
#> 6 XXX001  P01     BASELINE      LAST     SBCVA       6    NA NA    NA      NA   
#> 7 XXX001  P01     WEEK 2        LAST     SBCVA      -3    NA NA    NA      NA   
#> 8 XXX001  P01     WEEK 4        LAST     SBCVA     -10    NA NA    NA      NA   
#> 9 XXX001  P01     WEEK 6        LAST     SBCVA      12    NA NA    NA      NA   
#> # ℹ 3 more variables: CRIT2FL <chr>, CRIT3 <chr>, CRIT3FL <chr>
```
