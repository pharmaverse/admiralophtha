#' ETDRS --> LogMAR conversion
#'
#' Convert ETDRS --> LogMAR conversion in (`AVAL`)
#'
#' @param variable variable containing ETDRS score to convert to logMAR
#'
#' @details
#' ETDRS is converted by logMAR = -0.02 * ETDRS + 1.7
#'
#' @author Rachel Linacre
#'
#' @return The input variable converted
#' @keywords der_ophtha
#' @export
#'
#' @examples
#' library(tibble)
#' library(dplyr)
#' library(admiral)
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
#' adbcva <- adbcva %>% mutate(AVAL = calculate_etdrs_to_logmar(AVAL))
calculate_etdrs_to_logmar <- function(value) {
  -0.02 * value + 1.7
}
