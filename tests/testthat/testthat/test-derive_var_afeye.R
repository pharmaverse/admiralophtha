test_that("AFEYE is derived correctly", {
  adae <- tibble::tribble(
    ~STUDYID, ~USUBJID, ~AELOC, ~AELAT, ~STUDYEYE,
    "XXX001", "P01", "EYE", "LEFT", "RIGHT",
    "XXX001", "P02", "", "", "LEFT",
    "XXX001", "P04", "EYE", "RIGHT", "BILATERAL",
    "XXX001", "P05", "EYE", "RIGHT", "RIGHT",
    "XXX002", "P01", "EYE", "LEFT", "RIGHT",
  )
  expected_output <- tibble::tribble(
    ~STUDYID, ~USUBJID, ~AELOC, ~AELAT, ~STUDYEYE, ~AFEYE,
    "XXX001", "P01", "EYE", "LEFT", "RIGHT", "Fellow Eye",
    "XXX001", "P02", "", "", "LEFT", "",
    "XXX001", "P04", "EYE", "RIGHT", "BILATERAL", "Study Eye",
    "XXX001", "P05", "EYE", "RIGHT", "RIGHT", "Study Eye",
    "XXX002", "P01", "EYE", "LEFT", "RIGHT", "Fellow Eye"
  )

  admiraldev::expect_dfs_equal(
    derive_var_afeye(adae, vars(AELOC), vars(AELAT)),
    expected_output,
    keys = c("STUDYID", "USUBJID", "AELAT")
  )
})
