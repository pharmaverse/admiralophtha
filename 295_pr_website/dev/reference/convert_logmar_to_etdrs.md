# LogMAR –\> ETDRS conversion

Convert LogMAR score to ETDRS units

## Usage

``` r
convert_logmar_to_etdrs(value)
```

## Arguments

- value:

  object containing logMAR score to convert to ETDRS.

  Permitted values

  :   a numeric value, e.g. `2`, `-5`, `1.4`

  Default value

  :   none

## Value

The input value converted to ETDRS units.

## Details

logMAR value converted to ETDRS as:

\$\$ETDRS = -(logMAR - 1.7) / 0.02\$\$

Source for conversion formula: Beck, R.W., et al. A computerized method
of visual acuity testing. American Journal of Ophthalmology, 135(2),
pp.194-205. doi:https://doi.org/10.1016/s0002-9394(02)01825-1.

## Author

Nandini R Thampi

## Examples

``` r
library(tibble)
library(dplyr)
library(admiral)

oe <- tribble(
  ~STUDYID, ~USUBJID, ~OETESTCD, ~OEMETHOD, ~OESTRESN,
  "XXX001", "P01", "VACSCORE", "logMAR EYE CHART", 1.08,
  "XXX001", "P02", "VACSCORE", "logMAR EYE CHART", 1.66,
  "XXX001", "P03", "VACSCORE", "logMAR EYE CHART", 1.60,
  "XXX001", "P04", "VACSCORE", "ETDRS EYE CHART", 57,
  "XXX001", "P05", "VACSCORE", "ETDRS EYE CHART", 1
)

adbcva <- oe %>%
  filter(OETESTCD == "VACSCORE" & toupper(OEMETHOD) == "LOGMAR EYE CHART") %>%
  mutate(OESTRESN = convert_logmar_to_etdrs(OESTRESN))
```
