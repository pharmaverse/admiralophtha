# Adds `CRITx`/`CRITxFL` pairs to BCVA dataset

**\[deprecated\]** The `derive_var_bcvacritxfl()` function has been
deprecated in favor of
[`admiral::derive_vars_crit_flag()`](https:/pharmaverse.github.io/admiral/v1.5.0/cran-release/reference/derive_vars_crit_flag.html) -
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
