#' Derive Study Eye
#'
#' Derive Study Eye (`STUDYEYE`) in the ADSL dataset
#'
#' @param dataset_adsl ADSL input dataset
#' @param dataset_sc SC input dataset
#'
#' @details
#' Study Eye is derived in ADSL using the "Study Eye selection" records
#' in the SC SDTM dataset.
#'
#' @author Edoardo Mancini
#'
#' @return The input ADSL dataset with an additional column named `STUDYEYE`
#' @keywords adsl derivation ophthalmology
#' @export
#'
#' @examples
#' adsl <- tibble::tribble(
#'   ~USUBJID
#'   "P01",
#'   "P02",
#'   "P03",
#'   "P04",
#'   "P05",
#' )
#'
#' sc <- tibble::tribble(
#'   ~USUBJID, ~SCTESTCD,~SCSTRESC
#'   "P01", "FOCID", "OS",
#'   "P01", "ACOHORT", "COHORT1,
#'   "P02", "FOCID", "OD",
#'   "P02", "ACOHORT", "COHORT3",
#'   "P04", "FOCID", "OU",
#'   "P05", "FOCID", "OD"
#' )
#'
#' derive_var_studyeye(adsl, sc)

derive_var_studyeye <- function(dataset_adsl, dataset_sc) {

  seye_cat <- function(seye) {
    case_when(
      seye == "OS" ~ "LEFT",
      seye == "OD" ~ "RIGHT",
      seye == "OU" ~ "BILATERAL",
      TRUE ~ ""
    )
  }

  admiral::derive_var_merged_cat(
    dataset_adsl,
    dataset_add = dataset_sc,
    by_vars = vars(USUBJID),
    order = NULL,
    filter_add = SCTESTCD == "FOCID",
    new_var = STUDYEYE,
    source_var = SCSTRESC,
    cat_fun = seye_cat,
    mode = NULL
  )

}
