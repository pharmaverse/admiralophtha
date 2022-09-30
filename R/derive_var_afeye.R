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
#' @keywords derivation ophthalmology
#' @export
#'
#' @examples
#' library(tibble)
#' library(admiral)
#'
#'
#' adae <- tribble(
#'   ~STUDYID, ~USUBJID, ~STUDYEYE, ~AELOC, ~AELAT,
#'   "XXX001", "P01", "RIGHT", "EYE", "RIGHT",
#'   "XXX001", "P01", "RIGHT", "EYE", "LEFT",
#'   "XXX001", "P02", "LEFT", "", "",
#'   "XXX001", "P02", "LEFT", "EYE", "LEFT",
#'   "XXX001", "P04", "BILATERAL", "EYE", "RIGHT",
#'   "XXX001", "P05", "RIGHT", "EYE", "RIGHT"
#' )
#'
#' derive_var_afeye(adae, vars(AELOC), vars(AELAT))
derive_var_afeye <- function(dataset_occ, loc_var, lat_var) {
  dataset_occ  %>%
    mutate(AFEYE = case_when(
      !!sym(vars2chr(loc_var)) == "" ~ "",
      toupper(STUDYEYE) == "BILATERAL" ~ "Study Eye",
      toupper(!!sym(vars2chr(lat_var))) == toupper(STUDYEYE) ~ "Study Eye",
      toupper(!!sym(vars2chr(lat_var))) != toupper(STUDYEYE) ~ "Fellow Eye",
      TRUE ~ ""
    ))
}
