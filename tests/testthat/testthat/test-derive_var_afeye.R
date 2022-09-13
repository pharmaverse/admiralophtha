test_that("AFEYE is derived correctly", {
  adsl <- tibble::tribble(
     ~STUDYID, ~USUBJID, ~STUDYEYE,
      "XXX001", "P01", "RIGHT",
      "XXX001", "P02", "LEFT",
      "XXX001", "P03", "LEFT",
      "XXX001", "P04", "BILATERAL",
      "XXX001", "P05", "RIGHT",
      "XXX002", "P01", "RIGHT"
     )

  adae <- tibble::tribble(
       ~STUDYID, ~USUBJID, ~AELOC, ~AELAT,
       "XXX001", "P01", "EYE", "LEFT",
       "XXX001", "P02", "", "",
       "XXX001", "P04", "EYE", "RIGHT",
       "XXX001", "P05", "EYE", "RIGHT",
       "XXX002", "P01", "EYE", "LEFT"
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
    derive_var_afeye(adae, adsl, vars(AELOC), vars(AELAT)),
    expected_output,
    keys = c("STUDYID", "USUBJID", "AELAT")
  )
})
