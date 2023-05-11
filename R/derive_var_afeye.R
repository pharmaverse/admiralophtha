#' Derive Affected Eye
#'
#' Derive Affected Eye (`AFEYE`) in occurrence datasets
#'
#' @param dataset_occ Input Occurence dataset
#' @param loc_var Location variable
#' @param lat_var Laterality variable
#'
#' @details
#' Affected Eye is derived in the occurrence dataset using laterality and Study
#' Eye. This assumes Study Eye has already been added from ADSL.
#'
#' @author Lucy Palmen
#'
#' @return The input occurrence dataset with Affected Eye (AFEYE) added.
#' @keywords der_occds
#' @export
#'
#' @examples
#' library(tibble)
#' library(admiral)
#'
#' adae <- tribble(
#'   ~STUDYID, ~USUBJID, ~STUDYEYE, ~AELOC, ~AELAT,
#'   "XXX001", "P01", "RIGHT", "EYE", "RIGHT",
#'   "XXX001", "P01", "RIGHT", "EYE", "LEFT",
#'   "XXX001", "P01", "RIGHT", "EYE", "",
#'   "XXX001", "P01", "RIGHT", "", "RIGHT",
#'   "XXX001", "P02", "LEFT", "", "",
#'   "XXX001", "P02", "LEFT", "EYE", "LEFT",
#'   "XXX001", "P04", "BILATERAL", "EYE", "RIGHT",
#'   "XXX001", "P05", "RIGHT", "EYE", "RIGHT",
#'   "XXX001", "P05", "RIGHT", "EYE", "BILATERAL",
#'   "XXX001", "P06", "BILATERAL", "", "",
#'   "XXX001", "P06", "BILATERAL", "", "RIGHT",
#'   "XXX001", "P07", "BILATERAL", "EYE", "BILATERAL",
#'   "XXX001", "P08", "", "EYE", "BILATERAL",
#' )
#'
#' adae <- derive_var_afeye(adae, AELOC, AELAT)
derive_var_afeye <- function(dataset_occ, loc_var, lat_var) {
  loc_var <- assert_symbol(enexpr(loc_var))
  lat_var <- assert_symbol(enexpr(lat_var))
  assert_data_frame(dataset_occ, required_vars = expr_c(loc_var, lat_var, exprs(STUDYEYE)))

  dataset_occ %>%
    mutate(AFEYE = case_when(
      STUDYEYE != "" & !!lat_var == "BILATERAL" & !!loc_var == "EYE" ~ "Both Eyes",
      toupper(STUDYEYE) == "BILATERAL" & !!lat_var != "" & !!loc_var == "EYE" ~ "Study Eye",
      toupper(!!lat_var) == toupper(STUDYEYE) & STUDYEYE != "" & !!lat_var != "" & !!loc_var == "EYE" ~ "Study Eye",
      toupper(!!lat_var) != toupper(STUDYEYE) & STUDYEYE != "" & !!lat_var != "" & !!loc_var == "EYE" ~ "Fellow Eye",
      TRUE ~ NA_character_
    ))
}
