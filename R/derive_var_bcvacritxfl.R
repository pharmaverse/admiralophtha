#' Add `CRITx`/`CRITxFL` pair to BCVA dataset
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#' The `derive_var_bcvacritxfl_util()`
#' function has been deprecated in favor of `admiral::derive_vars_crit_flag()` - please see
#' the [criterion flag section of the
#' ADBCVA vignette](https://pharmaverse.github.io/admiralophtha/articles/adbcva.html#critflags)
#' for more details.
#'
#' Helper function for `derive_var_bcvacritxfl()` that adds a criterion variable `CRITx` and
#' its corresponding flag `CRITxFL` to a dataset containing BCVA records
#'
#' @param dataset Input dataset (usually ADBCVA).
#' @permitted [dataset]
#' @param crit_var Variable with respect to which `CRITx`/`CRITxFL` are derived
#' (usually `CHG` or `AVAL`).
#' @permitted [var]
#' @param critx_text String containing the text for `CRITx` variable.
#' @permitted [char_scalar]
#' @param critxfl_cond String containing R code detailing the criterion to be satisfied
#' for `CRITxFL` variable to be equal to "Y".
#' @permitted a character scalar, i.e., a character vector of length one, containing
#'   evaluable R code, e.g. `"AVAL < 2"`
#' @param counter Integer detailing the value of x to use in `CRITxFL`.
#' @permitted [pos_int]
#' @param bcva_range Numeric vector detailing lower and upper change in
#' BCVA limits (`bcva_range` will be called in `critxfl_cond` if the criterion
#' stipulates that change in BCVA lie inside some range).
#' @permitted a numeric vector of length two, e.g. `c(1, 2)`
#' @param bcva_uplim Numeric value detailing highest change in BCVA limit (`bcva_uplim`
#' will be called in `critxfl_cond` if the criterion stipulates that change in BCVA
#' lie below some upper limit).
#' @permitted [num]
#' @param bcva_lowlim Numeric value detailing lowest change in BCVA limit (`bcva_lowlim`
#' will be called in `critxfl_cond` if the criterion stipulates that change in BCVA
#' lie above some lower limit).
#' @permitted [num]
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
#' @return The input BCVA dataset with additional columns `CRITx`, `CRITxFL`.
#'
#' @family deprecated
#' @keywords internal deprecated

derive_var_bcvacritxfl_util <- function(dataset,
                                        crit_var,
                                        critx_text,
                                        critxfl_cond,
                                        counter,
                                        bcva_range = NULL,
                                        bcva_uplim = NULL,
                                        bcva_lowlim = NULL) {
  deprecate_stop(
    when = "1.5.0",
    what = "admiralophtha::derive_var_bcvacritxfl_util()",
    with = "admiral::derive_vars_crit_flag()",
    details = c(
      i = "See admiralophtha's guidance on creating BCVA criterion flags here:
      https://pharmaverse.github.io/admiralophtha/articles/adbcva.html#critflags"
    )
  )
}

#' Adds `CRITx`/`CRITxFL` pairs to BCVA dataset
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#' The `derive_var_bcvacritxfl()`
#' function has been deprecated in favor of `admiral::derive_vars_crit_flag()` - please see
#' the [criterion flag section of the
#' ADBCVA vignette](https://pharmaverse.github.io/admiralophtha/articles/adbcva.html#critflags)
#' for more details.
#'
#' Adds a criterion variables `CRITx` and their corresponding flags `CRITxFL` to a
#' dataset containing BCVA records
#'
#' @param dataset Input dataset containing BCVA data (usually ADBCVA).
#' @permitted [dataset]
#' @param crit_var Variable with respect to which `CRITx`/`CRITxFL` are derived
#' (usually `CHG` or `AVAL`).
#' @permitted [var]
#' @param additional_text string containing additional text to append to `CRITx`.
#' @permitted [char_scalar]
#' @param critxfl_index positive integer detailing the first value of x to use
#' in `CRITxFL`. If not supplied, the function takes the first available value of
#' x, counting up from x = 1.
#' @permitted [pos_int]
#' @param bcva_ranges List of numeric vectors. For each
#' vector `c(a,b)` in `bcva_ranges`, a pair of variables `CRITx`, `CRITxFL` is created
#' with the condition: `a <=  crit_var <= b`. If criterion flags of that type are not
#' required, then leave as `NULL`.
#' @permitted a list containing one or more numeric vectors, each of length two. E.g.
#'   `list(c(1, 2), c(3, 4)`
#' @param bcva_uplims List containing one or more numeric elements. For each
#' element a in `bcva_uplims`, a pair of variables `CRITx`, `CRITxFL` is created
#' with the condition: `crit_var <= a`. If criterion flags of that type are not
#' required, then leave as `NULL`.
#' @permitted a list containing one or more numeric scalars. E.g. `list(2, -4)`
#' @param bcva_lowlims List containing one or more numeric elements. For each
#' element b in `bcva_lowlims`, a pair of variables `CRITx`, `CRITxFL` is created
#' with the condition: `crit_var >= b`. If criterion flags of that type are not required,
#' then leave as `NULL`.
#' @permitted a list containing one or more numeric scalars. E.g. `list(2, -4)`
#'
#' @details
#' This function works by calling `derive_var_bcvacritxfl()` once for each of the
#' elements in `bcva_ranges`, `bcva_uplims` and `bcva_lowlims`.
#' NOTE: if `crit_var` is equal to `NA`, then the resulting criterion flag is also marked
#' as `NA`.
#'
#' @author Edoardo Mancini
#'
#' @return The input BCVA dataset with additional column pairs`CRITx`, `CRITxFL`.
#' @keywords der_ophtha deprecated
#' @family deprecated
#' @export
#'
derive_var_bcvacritxfl <- function(dataset,
                                   crit_var,
                                   bcva_ranges = NULL,
                                   bcva_uplims = NULL,
                                   bcva_lowlims = NULL,
                                   additional_text = "",
                                   critxfl_index = NULL) {
  deprecate_stop(
    when = "1.5.0",
    what = "admiralophtha::derive_var_bcvacritxfl()",
    with = "admiral::derive_vars_crit_flag()",
    details = c(
      i = "See admiralophtha's guidance on creating BCVA criterion flags here:
      https://pharmaverse.github.io/admiralophtha/articles/adbcva.html#critflags"
    )
  )
}
