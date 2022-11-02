#' @name create_ae_test_data.R

#' @title create AE test data for ADMIRAL Ophtha

#' @details add AELAT to ADMIRAL AE test data

#' Input - admiral_ae

#' @author Ritika Aggarwal

library(admiral)
library(admiral.test) # contains test datasets from previous ADMIRAL project
library(dplyr)


# create possible AELAT values - as collected on CRF ----
lat <- c("LEFT", "RIGHT", "BOTH")

# read ADMIRAL AE test data ----
admiralophtha_ae <- admiral_ae

# create AELAT variable ----
# with random assignment of lat values where AESOC is "EYE DISORDERS"

admiralophtha_ae$AELAT <- ifelse(admiralophtha_ae$AESOC == "EYE DISORDERS",
  apply(admiralophtha_ae, 1, function(x) sample(lat, 1)), ""
)

# Save dataset ----
save(admiralophtha_ae, file = "data/admiralophtha_ae.rds")
