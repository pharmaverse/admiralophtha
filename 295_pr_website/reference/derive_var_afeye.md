# Derive Affected Eye

Derive Affected Eye (`AFEYE`) in occurrence datasets

## Usage

``` r
derive_var_afeye(dataset, loc_var, lat_var, loc_vals = "EYE")
```

## Arguments

- dataset:

  Input dataset.

  Permitted values

  :   a dataset, i.e., a `data.frame` or tibble

  Default value

  :   none

- loc_var:

  Location variable, usually `XXLOC`.

  Permitted values

  :   an unquoted symbol, e.g., `AVAL`

  Default value

  :   none

- lat_var:

  Laterality variable, usually `XXLAT`.

  Permitted values

  :   an unquoted symbol, e.g., `AVAL`

  Default value

  :   none

- loc_vals:

  `xxLOC` values for which `AFEYE` is derived.

  Permitted values

  :   a character vector, e.g. `c("EYE", "RETINA")`

  Default value

  :   `"EYE"`

## Value

The input occurrence dataset with Affected Eye (`AFEYE`) added.

## Details

Affected Eye is derived in the occurrence dataset using laterality and
Study Eye. This assumes Study Eye has already been added from ADSL.

## Author

Lucy Palmen

## Examples

``` r
library(tibble)
library(admiral)

adae1 <- tribble(
  ~STUDYID, ~USUBJID, ~STUDYEYE, ~AELOC, ~AELAT,
  "XXX001", "P01", "RIGHT", "EYE", "RIGHT",
  "XXX001", "P01", "RIGHT", "EYE", "LEFT",
  "XXX001", "P01", "RIGHT", "EYE", "",
  "XXX001", "P01", "RIGHT", "", "RIGHT",
  "XXX001", "P02", "LEFT", "", "",
  "XXX001", "P02", "LEFT", "EYE", "LEFT",
  "XXX001", "P04", "BILATERAL", "EYE", "RIGHT",
  "XXX001", "P05", "RIGHT", "EYE", "RIGHT",
  "XXX001", "P05", "RIGHT", "EYE", "BILATERAL",
  "XXX001", "P06", "BILATERAL", "", "",
  "XXX001", "P06", "BILATERAL", "", "RIGHT",
  "XXX001", "P07", "BILATERAL", "EYE", "BILATERAL",
  "XXX001", "P08", "", "EYE", "BILATERAL",
  "XXX001", "P09", "NONSENSE", "EYE", "BILATERAL",
  "XXX001", "P09", "BILATERAL", "EYE", "NONSENSE",
  "XXX001", "P09", "BILATERAL", "NONSENSE", "BILATERAL",
  "XXX001", "P10", "RIGHT", "EYE", "BOTH"
)

derive_var_afeye(adae1, loc_var = AELOC, lat_var = AELAT)
#> # A tibble: 17 × 6
#>    STUDYID USUBJID STUDYEYE    AELOC      AELAT       AFEYE     
#>    <chr>   <chr>   <chr>       <chr>      <chr>       <chr>     
#>  1 XXX001  P01     "RIGHT"     "EYE"      "RIGHT"     Study Eye 
#>  2 XXX001  P01     "RIGHT"     "EYE"      "LEFT"      Fellow Eye
#>  3 XXX001  P01     "RIGHT"     "EYE"      ""          NA        
#>  4 XXX001  P01     "RIGHT"     ""         "RIGHT"     NA        
#>  5 XXX001  P02     "LEFT"      ""         ""          NA        
#>  6 XXX001  P02     "LEFT"      "EYE"      "LEFT"      Study Eye 
#>  7 XXX001  P04     "BILATERAL" "EYE"      "RIGHT"     Study Eye 
#>  8 XXX001  P05     "RIGHT"     "EYE"      "RIGHT"     Study Eye 
#>  9 XXX001  P05     "RIGHT"     "EYE"      "BILATERAL" Both Eyes 
#> 10 XXX001  P06     "BILATERAL" ""         ""          NA        
#> 11 XXX001  P06     "BILATERAL" ""         "RIGHT"     NA        
#> 12 XXX001  P07     "BILATERAL" "EYE"      "BILATERAL" Both Eyes 
#> 13 XXX001  P08     ""          "EYE"      "BILATERAL" NA        
#> 14 XXX001  P09     "NONSENSE"  "EYE"      "BILATERAL" NA        
#> 15 XXX001  P09     "BILATERAL" "EYE"      "NONSENSE"  NA        
#> 16 XXX001  P09     "BILATERAL" "NONSENSE" "BILATERAL" NA        
#> 17 XXX001  P10     "RIGHT"     "EYE"      "BOTH"      NA        

adae2 <- tribble(
  ~STUDYID, ~USUBJID, ~STUDYEYE, ~AELOC, ~AELAT,
  "XXX001", "P01", "RIGHT", "EYES", "RIGHT",
  "XXX001", "P02", "RIGHT", "RETINA", "LEFT",
  "XXX001", "P03", "LEFT", "", ""
)

derive_var_afeye(adae2, loc_var = AELOC, lat_var = AELAT, loc_vals = c("EYES", "RETINA"))
#> # A tibble: 3 × 6
#>   STUDYID USUBJID STUDYEYE AELOC    AELAT   AFEYE     
#>   <chr>   <chr>   <chr>    <chr>    <chr>   <chr>     
#> 1 XXX001  P01     RIGHT    "EYES"   "RIGHT" Study Eye 
#> 2 XXX001  P02     RIGHT    "RETINA" "LEFT"  Fellow Eye
#> 3 XXX001  P03     LEFT     ""       ""      NA        
```
