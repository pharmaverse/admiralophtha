test_that("AFEYE is derived correctly", {
  adae1 <- tibble::tribble(
    ~STUDYID, ~USUBJID, ~STUDYEYE, ~AELOC, ~AELAT,
    "XXX001", "P01", "RIGHT", "EYE", "RIGHT",
    "XXX001", "P01", "RIGHT", "EYE", "LEFT",
    "XXX001", "P01", "RIGHT", "EYE", "",
    "XXX001", "P01", "RIGHT", "", "RIGHT",
    "XXX001", "P02", "LEFT", "", "",
    "XXX001", "P02", "LEFT", "EYE", "LEFT",
    "XXX001", "P04", "BILATERAL", "EYE", "RIGHT",
    "XXX001", "P05", "RIGHT", "EYE", "RIGHT",
    "XXX001", "P05", "RIGHT", "EYE", "BILATERAL",
    "XXX001", "P06", "BILATERAL", "", "",
    "XXX001", "P06", "BILATERAL", "", "RIGHT",
    "XXX001", "P07", "BILATERAL", "EYE", "BILATERAL",
    "XXX001", "P08", "", "EYE", "BILATERAL",
    "XXX001", "P09", "NONSENSE", "EYE", "BILATERAL",
    "XXX001", "P09", "BILATERAL", "EYE", "NONSENSE",
    "XXX001", "P09", "BILATERAL", "NONSENSE", "BILATERAL",
    "XXX001", "P10", "RIGHT", "EYE", "BOTH"
  )
  expected_output1 <- tibble::tribble(
    ~STUDYID, ~USUBJID, ~STUDYEYE, ~AELOC, ~AELAT, ~AFEYE,
    "XXX001", "P01", "RIGHT", "EYE", "RIGHT", "Study Eye",
    "XXX001", "P01", "RIGHT", "EYE", "LEFT", "Fellow Eye",
    "XXX001", "P01", "RIGHT", "EYE", "", NA_character_,
    "XXX001", "P01", "RIGHT", "", "RIGHT", NA_character_,
    "XXX001", "P02", "LEFT", "", "", NA_character_,
    "XXX001", "P02", "LEFT", "EYE", "LEFT", "Study Eye",
    "XXX001", "P04", "BILATERAL", "EYE", "RIGHT", "Study Eye",
    "XXX001", "P05", "RIGHT", "EYE", "RIGHT", "Study Eye",
    "XXX001", "P05", "RIGHT", "EYE", "BILATERAL", "Both Eyes",
    "XXX001", "P06", "BILATERAL", "", "", NA_character_,
    "XXX001", "P06", "BILATERAL", "", "RIGHT", NA_character_,
    "XXX001", "P07", "BILATERAL", "EYE", "BILATERAL", "Both Eyes",
    "XXX001", "P08", "", "EYE", "BILATERAL", NA_character_,
    "XXX001", "P09", "NONSENSE", "EYE", "BILATERAL", NA_character_,
    "XXX001", "P09", "BILATERAL", "EYE", "NONSENSE", NA_character_,
    "XXX001", "P09", "BILATERAL", "NONSENSE", "BILATERAL", NA_character_,
    "XXX001", "P10", "RIGHT", "EYE", "BOTH", NA_character_
  )

  expect_dfs_equal(
    derive_var_afeye(adae1, loc_var = AELOC, lat_var = AELAT),
    expected_output1,
    keys = c("STUDYID", "USUBJID", "AELOC", "AELAT")
  )

  adae2 <- tibble::tribble(
    ~STUDYID, ~USUBJID, ~STUDYEYE, ~AELOC, ~AELAT,
    "XXX001", "P01", "RIGHT", "EYE", "RIGHT",
    "XXX001", "P01", "RIGHT", "RETINA", "LEFT",
    "XXX001", "P01", "RIGHT", "", "",
  )
  expected_output2 <- tibble::tribble(
    ~STUDYID, ~USUBJID, ~STUDYEYE, ~AELOC, ~AELAT, ~AFEYE,
    "XXX001", "P01", "RIGHT", "EYE", "RIGHT", "Study Eye",
    "XXX001", "P01", "RIGHT", "RETINA", "LEFT", "Fellow Eye",
    "XXX001", "P01", "RIGHT", "", "", NA_character_,
  )

  expect_dfs_equal(
    derive_var_afeye(adae2, loc_var = AELOC, lat_var = AELAT, loc_vals = c("EYE", "RETINA")),
    expected_output2,
    keys = c("STUDYID", "USUBJID", "AELOC", "AELAT")
  )
})
