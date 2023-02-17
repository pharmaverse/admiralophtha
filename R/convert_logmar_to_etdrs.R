#' LogMAR --> ETDRS conversion
#'
#' Convert LogMAR score to ETDRS units
#'
#' @param value object containing logMAR score to convert to ETDRS
#'
#' @details
#' logMAR value converted to ETDRS as ETDRS = -(logMAR - 1.7) / 0.02
#'
#' @author Nandini R Thampi
#'
#' @return The input value converted to ETDRS units
#' @keywords der_ophtha
#' @export
#'
#' @examples
#' library(tibble)
#' library(dplyr)
#' library(admiral)
#'
#' oe <- tribble(
#'   ~STUDYID, ~USUBJID, ~OETESTCD, ~OEMETHOD, ~OESTRESN,
#'   "XXX001", "P01", "VACSCORE", "logMAR EYE CHART", 1.08,
#'   "XXX001", "P02", "VACSCORE", "logMAR EYE CHART", 1.66,
#'   "XXX001", "P03", "VACSCORE", "logMAR EYE CHART", 1.60,
#'   "XXX001", "P04", "VACSCORE", "ETDRS EYE CHART", 57,
#'   "XXX001", "P05", "VACSCORE", "ETDRS EYE CHART", 1
#' )
#'
#' adbcva <- oe %>%
#'   filter(OETESTCD == "VACSCORE" & toupper(OEMETHOD) == "LOGMAR EYE CHART") %>%
#'   mutate(OESTRESN = convert_logmar_to_etdrs(OESTRESN))
convert_logmar_to_etdrs <- function(value) {
  assert_numeric_vector(value)
  - (value - 1.7) / 0.02
}
