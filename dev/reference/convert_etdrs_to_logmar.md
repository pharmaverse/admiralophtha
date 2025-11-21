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
library(admiraldev)
#> 
#> Attaching package: ‘admiraldev’
#> The following objects are masked from ‘package:dplyr’:
#> 
#>     anti_join, filter_if, inner_join, left_join

adbcva <- tribble(
  ~STUDYID, ~USUBJID, ~AVAL,
  "XXX001", "P01", 5,
  "XXX001", "P02", 10,
  "XXX001", "P03", 15,
  "XXX001", "P04", 20,
  "XXX001", "P05", 25
)

adbcva <- adbcva %>% mutate(AVAL = convert_etdrs_to_logmar(AVAL))
```
