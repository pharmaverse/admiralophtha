# Derive Study Eye

Derive Study Eye (`STUDYEYE`) in the ADSL dataset

## Usage

``` r
derive_var_studyeye(dataset_adsl, dataset_sc, sctestcd_value = "FOCID")
```

## Arguments

- dataset_adsl:

  ADSL input dataset.

  Permitted values

  :   a dataset, i.e., a `data.frame` or tibble

  Default value

  :   none

- dataset_sc:

  SC input dataset.

  Permitted values

  :   a dataset, i.e., a `data.frame` or tibble

  Default value

  :   none

- sctestcd_value:

  `SCTESTCD` value flagging Study Eye selection records.

  Permitted values

  :   a character scalar, i.e., a character vector of length one

  Default value

  :   `"FOCID"`

## Value

The input ADSL dataset with an additional column named `STUDYEYE`.

## Details

Study Eye is derived in ADSL using the "Study Eye selection" records in
the SC SDTM dataset.

## Author

Edoardo Mancini

## Examples

``` r
library(tibble)
library(admiral)

adsl <- tribble(
  ~STUDYID, ~USUBJID,
  "XXX001", "P01",
  "XXX001", "P02",
  "XXX001", "P03",
  "XXX001", "P04",
  "XXX001", "P05"
)

sc <- tribble(
  ~STUDYID, ~USUBJID, ~SCTESTCD, ~SCSTRESC,
  "XXX001", "P01", "FOCID", "OS",
  "XXX001", "P01", "ACOHORT", "COHORT1",
  "XXX001", "P02", "FOCID", "OD",
  "XXX001", "P02", "ACOHORT", "COHORT3",
  "XXX001", "P04", "FOCID", "OU",
  "XXX001", "P05", "FOCID", "OD",
  "XXX001", "P06", "FOCID", "OS"
)

derive_var_studyeye(adsl, sc)
#> # A tibble: 5 × 3
#>   STUDYID USUBJID STUDYEYE   
#>   <chr>   <chr>   <chr>      
#> 1 XXX001  P01     "LEFT"     
#> 2 XXX001  P02     "RIGHT"    
#> 3 XXX001  P03     ""         
#> 4 XXX001  P04     "BILATERAL"
#> 5 XXX001  P05     "RIGHT"    
```
