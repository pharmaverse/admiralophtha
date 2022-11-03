test_that("STUDYEYE is derived correctly", {
  input <- tibble::tribble(
    ~STUDYID, ~USUBJID,
    "XXX001", "P01",
    "XXX001", "P02",
    "XXX001", "P03",
    "XXX001", "P04",
    "XXX001", "P05",
    "XXX001", "P06",
    "XXX002", "P01",
  )

  sc1 <- tibble::tribble(
    ~STUDYID, ~USUBJID, ~SCTESTCD, ~SCSTRESC,
    "XXX001", "P01", "FOCID", "OS",
    "XXX001", "P01", "ACOHORT", "COHORT1",
    "XXX001", "P02", "FOCID", "OD",
    "XXX001", "P02", "ACOHORT", "COHORT3",
    "XXX001", "P04", "FOCID", "OU",
    "XXX001", "P05", "FOCID", "OD",
    "XXX001", "P06", "FOCID", "OP",
    "XXX002", "P01", "FOCID", "OS"
  )

  sc2 <- tibble::tribble(
    ~STUDYID, ~USUBJID, ~SCTESTCD, ~SCSTRESC,
    "XXX001", "P01", "STDEYE", "OS",
    "XXX001", "P01", "ACOHORT", "COHORT1",
    "XXX001", "P02", "STDEYE", "OD",
    "XXX001", "P02", "ACOHORT", "COHORT3",
    "XXX001", "P04", "STDEYE", "OU",
    "XXX001", "P05", "STDEYE", "OD",
    "XXX001", "P06", "STDEYE", "OP",
    "XXX002", "P01", "STDEYE", "OS"
  )

  expected_output <- tibble::tribble(
    ~STUDYID, ~USUBJID, ~STUDYEYE,
    "XXX001", "P01", "LEFT",
    "XXX001", "P02", "RIGHT",
    "XXX001", "P03", "",
    "XXX001", "P04", "BILATERAL",
    "XXX001", "P05", "RIGHT",
    "XXX001", "P06", "",
    "XXX002", "P01", "LEFT"
  )

  expect_dfs_equal(
    derive_var_studyeye(input, sc1),
    expected_output,
    keys = c("STUDYID", "USUBJID")
  )

  expect_dfs_equal(
    derive_var_studyeye(input, sc2, "STDEYE"),
    expected_output,
    keys = c("STUDYID", "USUBJID")
  )
})
