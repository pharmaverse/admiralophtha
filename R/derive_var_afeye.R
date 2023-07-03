#' Derive Affected Eye
#'
#' Derive Affected Eye (`AFEYE`) in occurrence datasets
#'
#' @param dataset_occ Input Occurence dataset
#' @param loc_var Location variable
#' @param lat_var Laterality variable
#' @param loc_vals `xxLOC`values for which `AFEYE` is derived
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
#'   "XXX001", "P09", "NONSENSE", "EYE", "BILATERAL",
#'   "XXX001", "P09", "BILATERAL", "EYE", "NONSENSE",
#'   "XXX001", "P09", "BILATERAL", "NONSENSE", "BILATERAL",
#'   "XXX001", "P10", "RIGHT", "EYE", "BOTH"
#' )
#'
#' adae <- derive_var_afeye(adae, AELOC, AELAT)
derive_var_afeye <- function(dataset_occ, loc_var, lat_var, loc_vals = "EYE", lat_vals = c("LEFT", "RIGHT", "BILATERAL")) {
  seye_vals <- c("LEFT", "RIGHT", "BILATERAL")
  loc_var <- assert_symbol(enexpr(loc_var))
  lat_var <- assert_symbol(enexpr(lat_var))
  assert_character_vector(loc_vals)
  assert_character_vector(seye_vals)
  assert_character_vector(lat_vals)
  assert_data_frame(dataset_occ, required_vars = expr_c(loc_var, lat_var, exprs(STUDYEYE)))

  if (!all(unique(dataset_occ[[lat_var]]) %in% lat_vals)) warning("Warning: value not in lat_vals")
  if (!all(unique(dataset_occ[[loc_var]]) %in% loc_vals)) warning("Warning: value not in loc_vals")
  if (!all(unique(dataset_occ$STUDYEYE) %in% seye_vals)) warning("Warning: STUDYEYE is expected to be 'LEFT', 'RIGHT' or 'BILATERAL'")

  dataset_occ %>%
    mutate(AFEYE = case_when(
      toupper(STUDYEYE) %in% seye_vals & !!lat_var == "BILATERAL" & !!loc_var %in% loc_vals ~ "Both Eyes",
      toupper(STUDYEYE) == "BILATERAL" & !!lat_var %in% lat_vals & !!loc_var %in% loc_vals ~ "Study Eye",
      toupper(!!lat_var) == toupper(STUDYEYE) & toupper(STUDYEYE) %in% seye_vals & !!lat_var %in% lat_vals & !!loc_var %in% loc_vals ~ "Study Eye",
      toupper(!!lat_var) != toupper(STUDYEYE) & toupper(STUDYEYE) %in% seye_vals & !!lat_var %in% lat_vals & !!loc_var %in% loc_vals ~ "Fellow Eye",
      TRUE ~ NA_character_
    ))
}
