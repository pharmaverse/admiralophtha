#' Derive Study Eye
#'
#' Derive Study Eye (`STUDYEYE`) in the ADSL dataset
#'
#' @param dataset_adsl ADSL input dataset
#' @param dataset_sc SC input dataset
#' @param sctestcd_value SCTESTCD value flagging Study Eye selection records. Default: "FOCID".
#'
#' @details
#' Study Eye is derived in ADSL using the "Study Eye selection" records
#' in the SC SDTM dataset.
#'
#' @author Edoardo Mancini
#'
#' @return The input ADSL dataset with an additional column named `STUDYEYE`
#' @keywords der_adsl
#' @export
#'
#' @examples
#' library(tibble)
#' library(admiral)
#'
#' adsl <- tribble(
#'   ~STUDYID, ~USUBJID,
#'   "XXX001", "P01",
#'   "XXX001", "P02",
#'   "XXX001", "P03",
#'   "XXX001", "P04",
#'   "XXX001", "P05"
#' )
#'
#' sc <- tribble(
#'   ~STUDYID, ~USUBJID, ~SCTESTCD, ~SCSTRESC,
#'   "XXX001", "P01", "FOCID", "OS",
#'   "XXX001", "P01", "ACOHORT", "COHORT1",
#'   "XXX001", "P02", "FOCID", "OD",
#'   "XXX001", "P02", "ACOHORT", "COHORT3",
#'   "XXX001", "P04", "FOCID", "OU",
#'   "XXX001", "P05", "FOCID", "OD",
#'   "XXX001", "P06", "FOCID", "OS"
#' )
#'
#' derive_var_studyeye(adsl, sc)
derive_var_studyeye <- function(dataset_adsl, dataset_sc, sctestcd_value = "FOCID") {
  assert_data_frame(dataset_sc, required_vars = exprs(STUDYID, USUBJID, SCTESTCD, SCSTRESC))
  assert_data_frame(dataset_adsl, required_vars = exprs(STUDYID, USUBJID))

  seye_cat <- function(seye) {
    case_when(
      seye == "OS" ~ "LEFT",
      seye == "OD" ~ "RIGHT",
      seye == "OU" ~ "BILATERAL",
      TRUE ~ ""
    )
  }

  derive_vars_merged(
    dataset_adsl,
    dataset_add = dataset_sc,
    by_vars = exprs(STUDYID, USUBJID),
    order = NULL,
    filter_add = SCTESTCD == !!sctestcd_value,
    new_var = exprs(tmp_STUDYEYE = SCSTRESC),
    mode = NULL,
    missing_values = exprs(tmp_STUDYEYE = "")
  ) %>%
    mutate(STUDYEYE = seye_cat(STUDYEYE))
}
