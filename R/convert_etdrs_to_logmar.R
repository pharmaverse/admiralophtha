#' ETDRS --> LogMAR conversion
#'
#' Convert ETDRS score to LogMAR units
#'
#' @param value object containing ETDRS score to convert to logMAR
#'
#' @details
#' ETDRS value converted to logMAR as logMAR = -0.02 * ETDRS + 1.7
#'
#' @author Rachel Linacre
#'
#' @return The input value converted converted to logMAR units
#' @keywords der_ophtha
#' @export
#'
#' @examples
#' library(tibble)
#' library(dplyr)
#' library(admiral)
#' library(admiraldev)
#'
#' adbcva <- tribble(
#'   ~STUDYID, ~USUBJID, ~AVAL,
#'   "XXX001", "P01", 5,
#'   "XXX001", "P02", 10,
#'   "XXX001", "P03", 15,
#'   "XXX001", "P04", 20,
#'   "XXX001", "P05", 25
#' )
#'
#' adbcva <- adbcva %>% mutate(AVAL = convert_etdrs_to_logmar(AVAL))
convert_etdrs_to_logmar <- function(value) {
  assert_numeric_vector(value)
  -0.02 * value + 1.7
}
