# Add `CRITx`/`CRITxFL` pair to BCVA dataset

**\[deprecated\]** The `derive_var_bcvacritxfl_util()` function has been
deprecated in favor of
[`admiral::derive_vars_crit_flag()`](https:/pharmaverse.github.io/admiral/v1.3.1/cran-release/reference/derive_vars_crit_flag.html) -
please see the [criterion flag section of the ADBCVA
vignette](https://pharmaverse.github.io/admiralophtha/articles/adbcva.html#critflags)
for more details.

Helper function for
[`derive_var_bcvacritxfl()`](https://pharmaverse.github.io/admiralophtha/dev/reference/derive_var_bcvacritxfl.md)
that adds a criterion variable `CRITx` and its corresponding flag
`CRITxFL` to a dataset containing BCVA records

## Usage

``` r
derive_var_bcvacritxfl_util(
  dataset,
  crit_var,
  critx_text,
  critxfl_cond,
  counter,
  bcva_range = NULL,
  bcva_uplim = NULL,
  bcva_lowlim = NULL
)
```

## Arguments

- dataset:

  Input dataset (usually ADBCVA).

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

- critx_text:

  String containing the text for `CRITx` variable.

  Permitted values

  :   a character scalar, i.e., a character vector of length one

  Default value

  :   none

- critxfl_cond:

  String containing R code detailing the criterion to be satisfied for
  `CRITxFL` variable to be equal to "Y".

  Permitted values

  :   a character scalar, i.e., a character vector of length one,
      containing evaluable R code, e.g. `"AVAL < 2"`

  Default value

  :   none

- counter:

  Integer detailing the value of x to use in `CRITxFL`.

  Permitted values

  :   a positive integer, e.g. `2` or `5`

  Default value

  :   none

- bcva_range:

  Numeric vector detailing lower and upper change in BCVA limits
  (`bcva_range` will be called in `critxfl_cond` if the criterion
  stipulates that change in BCVA lie inside some range).

  Permitted values

  :   a numeric vector of length two, e.g. `c(1, 2)`

  Default value

  :   `NULL`

- bcva_uplim:

  Numeric value detailing highest change in BCVA limit (`bcva_uplim`
  will be called in `critxfl_cond` if the criterion stipulates that
  change in BCVA lie below some upper limit).

  Permitted values

  :   a numeric value, e.g. `2`, `-5`, `1.4`

  Default value

  :   `NULL`

- bcva_lowlim:

  Numeric value detailing lowest change in BCVA limit (`bcva_lowlim`
  will be called in `critxfl_cond` if the criterion stipulates that
  change in BCVA lie above some lower limit).

  Permitted values

  :   a numeric value, e.g. `2`, `-5`, `1.4`

  Default value

  :   `NULL`

## Value

The input BCVA dataset with additional columns `CRITx`, `CRITxFL`.

## Details

The criterion for change in BCVA in `CRITxFL` can be of three types: (1)
value lies within some range; `a <= crit_var <= b`; (2) value is below
some upper limit; `crit_var <= a`; (3) value is above some lower limit;
`b <= crit_var`. For (1), `bcva_range` must be specified to this
function; for (2), `bcva_uplim`; for (3) `bcva_lowlim`. It is necessary
to supply at least one of these three arguments. NOTE: if `crit_var` is
equal to NA, then the resulting criterion flag is also marked as `NA`.

## See also

Other deprecated:
[`derive_var_bcvacritxfl()`](https://pharmaverse.github.io/admiralophtha/dev/reference/derive_var_bcvacritxfl.md)

## Author

Edoardo Mancini
