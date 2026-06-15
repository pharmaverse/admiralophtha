# ETDRS –\> LogMAR conversion

Convert ETDRS score to LogMAR units

## Usage

``` r
convert_etdrs_to_logmar(value)
```

## Arguments

- value:

  object containing ETDRS score to convert to logMAR.

  Permitted values

  :   a numeric value, e.g. `2`, `-5`, `1.4`

  Default value

  :   none

## Value

The input value converted converted to logMAR units.

## Details

ETDRS value converted to logMAR as:

\$\$logMAR = -0.02 \* ETDRS + 1.7\$\$

Source for conversion formula: Beck, R.W., et al. A computerized method
of visual acuity testing. American Journal of Ophthalmology, 135(2),
pp.194-205. doi:https://doi.org/10.1016/s0002-9394(02)01825-1.

## See also

[`convert_logmar_to_etdrs()`](https://pharmaverse.github.io/admiralophtha/dev/reference/convert_logmar_to_etdrs.md)

## Author

Rachel Linacre

## Examples

``` r
library(tibble)
library(dplyr)
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union
library(admiral)

oe <- tribble(
  ~STUDYID, ~USUBJID, ~OETESTCD, ~OEMETHOD, ~OESTRESN,
  "XXX001", "P01", "VACSCORE", "logMAR EYE CHART", 1.08,
  "XXX001", "P02", "VACSCORE", "logMAR EYE CHART", 1.66,
  "XXX001", "P03", "VACSCORE", "logMAR EYE CHART", 1.60,
  "XXX001", "P04", "VACSCORE", "ETDRS EYE CHART", 57,
  "XXX001", "P05", "VACSCORE", "ETDRS EYE CHART", 62
)

adbcva <- oe %>%
  filter(OETESTCD == "VACSCORE" & toupper(OEMETHOD) == "ETDRS EYE CHART") %>%
  mutate(OESTRESN = convert_etdrs_to_logmar(OESTRESN))
```
