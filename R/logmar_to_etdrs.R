#' Conversion of logMAR to ETDRS
#'
#' Convert logMAR value of (`OESTRESN`) to ETDRS value
#'
#' @param variable variable containing ETDRS score to convert to logMAR
#'
#' @details
#' logMAR value converted to ETDRS as ETDRS = -(logMAR - 1.7) / 0.02
#'
#' @author Nandini R Thampi
#'
#' @return The input variable converted to ETDRS value
#' @keywords
#' @export
#'
#' @examples
#' library(tibble)
#' library(dplyr)
#' library(admiral)
#'
#' oe <- tribble(
#'   ~STUDYID, ~USUBJID, ~OETESTCD, ~OEMETHOD, ~OESTRESN
#'   "XXX001", "P01", "VACSCORE", "logMAR EYE CHART", 1.08
#'   "XXX001", "P02", "VACSCORE", "logMAR EYE CHART", 1.66
#'   "XXX001", "P03", "VACSCORE", "logMAR EYE CHART", 1.60
#'   "XXX001", "P04", "VACSCORE", "ETDRS EYE CHART", 57
#'   "XXX001", "P05", "VACSCORE", "ETDRS EYE CHART", 1
#' )
#'
#' adbcva <- oe %>% filter(OETESTCD == "VACSCORE" & toupper(OEMETHOD) == "LOGMAR EYE CHART") %>% mutate(OESTRESN = logmar_to_etdrs(OESTRESN))

logmar_to_etdrs <- function(variable) {

  variable <- -(variable - 1.7) / 0.02

}
