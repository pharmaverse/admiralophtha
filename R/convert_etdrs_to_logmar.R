#' ETDRS --> LogMAR conversion
#'
#' Convert ETDRS score to LogMAR units
#'
#' @param value object containing ETDRS score to convert to logMAR
#'
#' @details
#' ETDRS value converted to logMAR as logMAR = -0.02 * ETDRS + 1.7
#'
#' Source for conversion formula:
#' Beck, R.W., et al. A computerized method of visual acuity testing.
#' American Journal of Ophthalmology, 135(2), pp.194-205.
#' doi:https://doi.org/10.1016/s0002-9394(02)01825-1.
#'
#' @author Rachel Linacre
#'
#' @return The input value converted converted to logMAR units
#' @keywords utils_fmt
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
