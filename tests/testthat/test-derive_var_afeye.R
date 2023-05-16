test_that("AFEYE is derived correctly", {
  adae <- tibble::tribble(
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
  )
  expected_output <- tibble::tribble(
    ~STUDYID, ~USUBJID, ~STUDYEYE, ~AELOC, ~AELAT, ~AFEYE,
    "XXX001", "P01", "RIGHT", "EYE", "RIGHT", "Study Eye",
    "XXX001", "P01", "RIGHT", "EYE", "LEFT", "Fellow Eye",
    "XXX001", "P01", "RIGHT", "EYE", "", NA,
    "XXX001", "P01", "RIGHT", "", "RIGHT", NA,
    "XXX001", "P02", "LEFT", "", "", NA,
    "XXX001", "P02", "LEFT", "EYE", "LEFT", "Study Eye",
    "XXX001", "P04", "BILATERAL", "EYE", "RIGHT", "Study Eye",
    "XXX001", "P05", "RIGHT", "EYE", "RIGHT", "Study Eye",
    "XXX001", "P05", "RIGHT", "EYE", "BILATERAL", "Both Eyes",
    "XXX001", "P06", "BILATERAL", "", "", NA,
    "XXX001", "P06", "BILATERAL", "", "RIGHT", NA,
    "XXX001", "P07", "BILATERAL", "EYE", "BILATERAL", "Both Eyes",
    "XXX001", "P08", "", "EYE", "BILATERAL", NA,
  )

  expect_dfs_equal(
    derive_var_afeye(adae, AELOC, AELAT),
    expected_output,
    keys = c("STUDYID", "USUBJID", "AELOC", "AELAT")
  )
})
