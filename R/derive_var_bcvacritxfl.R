#' Derive Study Eye
#'
#' Derive criterion flags for BCVA records in ophthalmology datasets
#'
#' @param dataset_adbcva ADBCVA input dataset
#'
#' @details
#' Criterion flags are derived.
#'
#' @author Edoardo Mancini, Yuki Matsunaga
#'
#' @return The input ADBCVA dataset with an additional columns `CRITx`, `CRITxFL`
#' @keywords der_ophtha
#' @export
#'
#' @examples
#'
derive_var_bcvacritxfl <- function(dataset_adbcva,
                                   paramcds,
                                   bcva_ranges,
                                   bcva_uptos,
                                   bcva_overs){
  assert_data_frame(dataset_adbcva, required_vars = vars(STUDYID, USUBJID, PARAMCD, CHG))

  # Find largest index of CRITxFL already present in dataset_adbcva
  critxfl_vars <- names(adbcva)[grepl("^CRT.*FL$", names(adbcva))]

  if (length(critxfl_vars) > 0){
    max_critxfl_num <- critxfl_vars %>%
      substr(5,5) %>%
      as.numeric() %>%
      max()
  }else{
    max_critxfl_num <- 0
  }

  # Start making CRITx, CRITxFL from next available index
  counter <- max_critxfl_num + 1

  for (bcva_range in bcva_ranges){

    # Construct name for CRITx and CRITxFL
    critx_name <- paste0("CRIT", counter)
    critxfl_name <- paste0(critx_name, "FL")

    # Derive CRITx, CRITxFL
    dataset_adbcva <- dataset_adbcva %>%
      mutate(
        !!critx_name := ifelse(PARAMCD %in% paramcds, paste0(bcva_range[1], " <= CHG <= ", bcva_range[2]), ""),
        !!critxfl_name := case_when(
          !(PARAMCD %in% paramcds) ~ "",
          !is.na(CHG) & bcva_range[1] <= CHG & CHG <= bcva_range[2] ~ "Y",
          TRUE ~ "N"
        )
      )

    counter <- counter + 1

  }

  for (bcva_upto in bcva_uptos){

    # Construct name for CRITx and CRITxFL
    critx_name <- paste0("CRIT", counter)
    critxfl_name <- paste0(critx_name, "FL")

    # Derive CRITx, CRITxFL
    dataset_adbcva <- dataset_adbcva %>%
      mutate(
        !!critx_name := ifelse(PARAMCD %in% paramcds, paste0(bcva_upto, " <= CHG"), ""),
        !!critxfl_name := case_when(
          !(PARAMCD %in% paramcds) ~ "",
          !is.na(CHG) & bcva_upto[1] <= CHG ~ "Y",
          TRUE ~ "N"
        )
      )

    counter <- counter + 1

  }

  for (bcva_over in bcva_overs){

    # Construct name for CRITx and CRITxFL
    critx_name <- paste0("CRIT", counter)
    critxfl_name <- paste0(critx_name, "FL")

    # Derive CRITx, CRITxFL
    dataset_adbcva <- dataset_adbcva %>%
      mutate(
        !!critx_name := ifelse(PARAMCD %in% paramcds, paste0(bcva_upto, " >= CHG"), ""),
        !!critxfl_name := case_when(
          !(PARAMCD %in% paramcds) ~ "",
          !is.na(CHG) & bcva_upto[1] >= CHG ~ "Y",
          TRUE ~ "N"
        )
      )

    counter <- counter + 1

  }

  return(dataset_adbcva)

}
