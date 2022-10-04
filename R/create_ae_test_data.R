#' Program Name : create_ae_test_data.R

#' Description : create AE test data for ADMIRAL Ophtha - add AELAT to ADMIRAL AE test data

#' Input : admiral_ae

#' Author : Ritika Aggarwal


library(admiral)
library(admiral.test) # contains test datasets from previous ADMIRAL project
library(dplyr)


# create possible AELAT values - as collected on CRF ----
lat = c("LEFT", "RIGHT","BOTH")

# read ADMIRAL AE test data ----
admiral_ophtha_ae = admiral_ae

# create AELAT variable ----
# with random assignment of lat values where AESOC is "EYE DISORDERS"

admiral_ophtha_ae$AELAT = ifelse(admiral_ophtha_ae$AESOC == "EYE DISORDERS",
                                 apply(admiral_ophtha_ae, 1, function(x) sample(lat, 1)),'')

# Save dataset ----
admiral_ae = admiral_ophtha_ae
save(admiral_ae, file = "data/admiral_ae.rda")

