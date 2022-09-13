#' Derive Affected Eye
#'
#' Derive Affected Eye (`AFEYE`) in occurrence datasets
#'
#' @param dataset_adsl ADSL input dataset
#' @param dataset_sc SC input dataset
#'
#' @details
#' Study Eye is added to occurrence dataset from ADSL and Affected Eye is
#' derived in the occurrence dataset using the laterality and Study Eye.
#'
#' @author Lucy Palmen
#'
#' @return The input ADSL dataset with an additional column named `STUDYEYE`.
#'         The occurrence dataset with laterality variable (xxLAT) and location
#'         variable (xxLOC).
#' @keywords adsl derivation ophthalmology
#' @export
#'
#' @examples
#' library(tibble)
#' library(admiral)
#'
#' adsl <- tribble(
#'   ~STUDYID, ~USUBJID, ~STUDYEYE,
#'   "XXX001", "P01", "RIGHT",
#'   "XXX001", "P02", "LEFT",
#'   "XXX001", "P03", "LEFT",
#'   "XXX001", "P04", "BILATERAL",
#'   "XXX001", "P05", "RIGHT"
#' )
#'
#'adae <- tribble(
#'   ~STUDYID, ~USUBJID, ~AELOC, ~AELAT,
#'   "XXX001", "P01", "EYE", "RIGHT",
#'   "XXX001", "P01", "EYE", "LEFT",
#'   "XXX001", "P02", "", "",
#'   "XXX001", "P02", "EYE", "LEFT",
#'   "XXX001", "P04", "EYE", "RIGHT",
#'   "XXX001", "P05", "EYE", "RIGHT"
#' )
#'
#' derive_var_afeye(adae, adsl, vars(AELOC), vars(AELAT))
#'

derive_var_afeye <- function(dataset_occ, dataset_adsl,  loc_var, lat_var) {

    dataset_occ %>% derive_vars_merged(
    dataset_add = dataset_adsl,
    by_vars = vars(STUDYID, USUBJID)) %>%
    mutate(AFEYE = case_when(
      !!sym(vars2chr(loc_var)) == "" ~ "",
      toupper(STUDYEYE) == "BILATERAL" ~ "Study Eye",
      toupper(!!sym(vars2chr(lat_var))) == toupper(STUDYEYE) ~ "Study Eye",
      toupper(!!sym(vars2chr(lat_var))) != toupper(STUDYEYE) ~ "Fellow Eye",
      TRUE ~ ""
    ))

}
