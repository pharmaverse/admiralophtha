## Test 1: STUDYEYE is derived correctly in normal case ----
test_that("derive_var_studyeye Test 1: STUDYEYE is derived correctly in normal case", {
  expected_output1 <- tibble::tribble(
    ~STUDYID, ~USUBJID, ~STUDYEYE,
    "XXX001", "P01", "LEFT",
    "XXX001", "P02", "RIGHT",
    "XXX001", "P03", "",
    "XXX001", "P04", "BILATERAL",
    "XXX001", "P05", "RIGHT",
    "XXX001", "P06", "",
    "XXX002", "P01", "LEFT"
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

  actual_output1 <-
    expected_output1 %>%
    select(-STUDYEYE) %>%
    derive_var_studyeye(sc1)

  expect_dfs_equal(
    actual_output1,
    expected_output1,
    keys = c("STUDYID", "USUBJID")
  )
})

## Test 2: STUDYEYE is derived correctly when parsing non-standard SCTESTCD ----
test_that("derive_var_studyeye Test 2: STUDYEYE is derived correctly when parsing non-standard SCTESTCD", { # nolint
  expected_output2 <- tibble::tribble(
    ~STUDYID, ~USUBJID, ~STUDYEYE,
    "XXX001", "P01", "LEFT",
    "XXX001", "P02", "RIGHT",
    "XXX001", "P03", "",
    "XXX001", "P04", "BILATERAL",
    "XXX001", "P05", "RIGHT",
    "XXX001", "P06", "",
    "XXX002", "P01", "LEFT"
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

  actual_output2 <-
    expected_output2 %>%
    select(-STUDYEYE) %>%
    derive_var_studyeye(sc2, "STDEYE")

  expect_dfs_equal(
    actual_output2,
    expected_output2,
    keys = c("STUDYID", "USUBJID")
  )
})
