#' Add `CRITx`/`CRITxFL` pair to ADBCVA dataset
#'
#' Helper function for `derive_var_bcvacritxfl` that adds a criterion variable `CRITx` and
#' its corresponding flag `CRITxFL` to an ADBCVA dataset.
#'
#' @param dataset Input dataset (ADBCVA).
#' @param dataset Variable with respect to which `CRITx`/`CRITxFL` are derived
#' (usually `CHG` or `AVAL`).
#' @param critx_text String containing the text for `CRITx` variable.
#' @param critxfl_cond String containing R code detailing the criterion to be satisfied
#' for `CRITxFL` variable to be equal to "Y".
#' @param counter Integer detailing the value of x to use in "CRITxFL".
#' @param bcva_range Numeric vector of length two detailing lower and upper change in
#' BCVA limits (`bcva_range` will be called in `critxfl_cond` if the criterion
#' stipulates that change in BCVA lie inside some range).
#' @param bcva_uplim Numeric value detailing highest change in BCVA limit (`bcva_uplim`
#' will be called in `critxfl_cond` if the criterion stipulates that change in BCVA
#' lie below some upper limit).
#' @param bcva_lowlim Numeric value detailing lowest change in BCVA limit (`bcva_lowlim`
#' will be called in `critxfl_cond` if the criterion stipulates that change in BCVA
#' lie above some lower limit).
#'
#' @details
#' The criterion for change in BCVA in `CRITxFL` can be of three types: (1) value lies
#' within some range; `a <= crit_var <= b`; (2) value is below some upper limit; `crit_var <= a`;
#' (3) value is above some lower limit; `b <= crit_var`. For (1), `bcva_range` must
#' be specified to this function; for (2), `bcva_uplim`; for (3) `bcva_lowlim`. It is
#' necessary to supply at least one of these three arguments.
#' NOTE: if `crit_var` is equal to NA, then the resulting criterion flag is also marked
#' as `NA`.
#'
#' @author Edoardo Mancini
#'
#' @return The input ADBCVA dataset with additional columns `CRITx`, `CRITxFL`.
#' @keywords internal

derive_var_bcvacritxfl_util <- function(dataset,
                                        crit_var,
                                        critx_text,
                                        critxfl_cond,
                                        counter,
                                        bcva_range = NULL,
                                        bcva_uplim = NULL,
                                        bcva_lowlim = NULL) {
  # Input checks
  assert_vars(crit_var)
  assert_data_frame(dataset, required_vars = c(exprs(STUDYID, USUBJID), crit_var))
  assert_character_vector(critx_text)
  assert_character_vector(critxfl_cond)
  assert_integer_scalar(counter)
  if (!is.null(bcva_range)) assert_numeric_vector(bcva_range)
  if (!is.null(bcva_uplim)) assert_integer_scalar(bcva_uplim)
  if (!is.null(bcva_lowlim)) assert_integer_scalar(bcva_lowlim)

  critx_name <- paste0("CRIT", counter)
  critxfl_name <- paste0(critx_name, "FL")

  dataset %>%
    mutate(
      !!critx_name := critx_text,
      !!critxfl_name := case_when(
        eval(parse(text = critxfl_cond)) ~ "Y",
        is.na(!!!crit_var) ~ NA_character_,
        TRUE ~ "N"
      )
    )
}

#' Adds `CRITx`/`CRITxFL` pairs to `ADBCVA` dataset
#'
#' Adds a criterion variables `CRITx` and their corresponding flags `CRITxFL` to an
#' ADBCVA dataset.
#'
#' @param dataset Input dataset containing BCVA data (usually `ADBCVA`).
#' @param dataset Variable with respect to which `CRITx`/`CRITxFL` are derived
#' (usually `CHG` or `AVAL`).
#' @param paramcds Vector of `PARAMCD` values for which to derive `CRITx` and `CRITxFL`.
#' @param basetype `BASETYPE` value for which to derive `CRITx` and `CRITxFL`.
#' @param additional_text string containing additional text to append to `CRITx`
#' @param critxfl_index positive integer detailing the first value of x to use
#' in "CRITxFL". If not supplied, the function takes the first available value of
#' x, counting up from x = 1.
#' @param bcva_ranges List containing one or more numeric vectors of length 2. For each
#' vector c(a,b) in `bcva_ranges`, a pair of variables `CRITx`, `CRITxFL` is created
#' with the condition: `a <=  crit_var <= b`. If criterion flags of that type are not
#' required, then leave as NULL.
#' @param bcva_uplims List containing one or more numeric elements. For each
#' element a in `bcva_uplims`, a pair of variables `CRITx`, `CRITxFL` is created
#' with the condition: `crit_var <= a`. If criterion flags of that type are not
#' required, then leave as NULL.
#' @param bcva_lowlims List containing one or more numeric elements. For each
#' element b in `bcva_lowlims`, a pair of variables `CRITx`, `CRITxFL` is created
#' with the condition: `crit_var >= b`. If criterion flags of that type are not required,
#' then leave as NULL.
#'
#' @details
#' This function works by calling `derive_var_bcvacritxfl`once for each of the
#' elements in `bcva_ranges`, `bcva_uplims` and `bcva_lowlims`.
#' NOTE: if `crit_var` is equal to `NA`, then the resulting criterion flag is also marked
#' as `NA`.
#'
#' @author Edoardo Mancini
#'
#' @return The input ADBCVA dataset with additional column pairs`CRITx`, `CRITxFL`.
#' @keywords der_ophtha
#' @export
#'
#' @examples
#' library(tibble)
#' library(admiral)
#' library(admiraldev)
#'
#' adbcva1 <- tribble(
#'   ~STUDYID, ~USUBJID, ~AVISIT, ~BASETYPE, ~PARAMCD, ~CHG,
#'   "XXX001", "P01", "BASELINE", "LAST", "SBCVA", 0,
#'   "XXX001", "P01", "WEEK 2", "LAST", "FBCVA", 2,
#'   "XXX001", "P02", "BASELINE", "LAST", "SBCVA", -13,
#'   "XXX001", "P02", "WEEK 2", "LAST", "FBCVA", 5,
#'   "XXX001", "P03", "BASELINE", "LAST", "SBCVA", NA,
#'   "XXX001", "P03", "WEEK 2", "LAST", "FBCVA", 17
#' )
#'
#' derive_var_bcvacritxfl(
#'   dataset = adbcva1,
#'   crit_var = exprs(CHG),
#'   bcva_ranges = list(c(0, 5), c(-5, -1), c(10, 15)),
#'   bcva_uplims = list(5, 10),
#'   bcva_lowlims = list(8),
#'   additional_text = ""
#' )
#'
#' adbcva2 <- tribble(
#'   ~STUDYID, ~USUBJID, ~AVISIT, ~BASETYPE, ~PARAMCD, ~AVAL, ~CHG,
#'   "XXX001", "P01", "BASELINE", "LAST", "SBCVA", 4, NA,
#'   "XXX001", "P01", "BASELINE", "LAST", "SBCVA", 6, NA,
#'   "XXX001", "P01", "AVERAGE BASELINE", "AVERAGE", "SBCVA", 5, NA,
#'   "XXX001", "P01", "WEEK 2", "LAST", "SBCVA", -3, NA,
#'   "XXX001", "P01", "WEEK 4", "LAST", "SBCVA", -10, NA,
#'   "XXX001", "P01", "WEEK 6", "LAST", "SBCVA", 12, NA,
#'   "XXX001", "P01", "WEEK 2", "AVERAGE", "SBCVA", -2, -7,
#'   "XXX001", "P01", "WEEK 4", "AVERAGE", "SBCVA", 6, 1,
#'   "XXX001", "P01", "WEEK 6", "AVERAGE", "SBCVA", 3, -2
#' )
#'
#' restrict_derivation(
#'   adbcva2,
#'   derivation = derive_var_bcvacritxfl,
#'   args = params(
#'     crit_var = exprs(CHG),
#'     bcva_ranges = list(c(0, 5), c(-10, 0)),
#'     bcva_lowlims = list(5),
#'     additional_text = " (AVERAGE)"
#'   ),
#'   filter = PARAMCD %in% c("SBCVA", "FBCVA") & BASETYPE == "AVERAGE"
#' )
#'
derive_var_bcvacritxfl <- function(dataset,
                                   crit_var,
                                   bcva_ranges = NULL,
                                   bcva_uplims = NULL,
                                   bcva_lowlims = NULL,
                                   additional_text = "",
                                   critxfl_index = NULL) {
  # Input checks
  assert_vars(crit_var)
  assert_data_frame(dataset, required_vars = c(exprs(STUDYID, USUBJID), crit_var))
  assert_character_scalar(additional_text)
  assert_integer_scalar(critxfl_index, optional = TRUE)
  if (!is.null(bcva_ranges)) lapply(bcva_ranges, assert_numeric_vector)
  if (!is.null(bcva_uplims)) lapply(bcva_uplims, assert_numeric_vector)
  if (!is.null(bcva_lowlims)) lapply(bcva_lowlims, assert_numeric_vector)

  # Identify first value of x to be used for CRITx/CRITxFL
  if (is.null(critxfl_index)) {
    # Find largest index of CRITxFL already present in the dataset
    critxfl_vars <- names(dataset)[grepl("^CRIT.*FL$", names(dataset))]

    if (length(critxfl_vars) > 0) {
      max_critxfl_num <- critxfl_vars %>%
        str_extract("[[:digit:]]+") %>%
        as.numeric() %>%
        max()
    } else {
      max_critxfl_num <- 0
    }
    # Start making CRITx, CRITxFL from next available index
    counter <- max_critxfl_num + 1
  } else {
    counter <- critxfl_index
  }

  # Get string containing crit_var's name
  crit_var_char <- vars2chr(crit_var)

  # Construct CRITx/CRITxFL pairs
  for (bcva_range in bcva_ranges) {
    dataset <- derive_var_bcvacritxfl_util(
      dataset,
      crit_var = crit_var,
      critx_text = paste0(bcva_range[1], " <= ", crit_var_char, " <= ", bcva_range[2], additional_text),
      critxfl_cond = paste0("!is.na(", crit_var_char, ") & bcva_range[1] <= ",
                            crit_var_char, " & ", crit_var_char," <= bcva_range[2]"),
      counter = counter,
      bcva_range = bcva_range
    )

    counter <- counter + 1
  }

  for (bcva_uplim in bcva_uplims) {
    dataset <- derive_var_bcvacritxfl_util(
      dataset,
      crit_var = crit_var,
      critx_text = paste0(crit_var_char, " <= ", bcva_uplim, additional_text),
      critxfl_cond = paste0("!is.na(", crit_var_char, ") & ", crit_var_char, " <= bcva_uplim[1]"),
      counter = counter,
      bcva_uplim = bcva_uplim
    )

    counter <- counter + 1
  }

  for (bcva_lowlim in bcva_lowlims) {
    dataset <- derive_var_bcvacritxfl_util(
      dataset,
      crit_var = crit_var,
      critx_text = paste0(crit_var_char, " >= ", bcva_lowlim, additional_text),
      critxfl_cond = paste0("!is.na(", crit_var_char, ") & ", crit_var_char, " >= bcva_lowlim[1]"),
      counter = counter,
      bcva_lowlim = bcva_lowlim
    )

    counter <- counter + 1
  }

  return(dataset)
}
