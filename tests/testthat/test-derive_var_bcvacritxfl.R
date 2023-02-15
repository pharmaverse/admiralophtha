test_that("Criterion flags derived correctly", {
  input1 <- tibble::tribble(
    ~STUDYID, ~USUBJID, ~BASETYPE, ~PARAMCD, ~CHG,
    "XXX001", "P01", "LAST", "SBCVA", 0,
    "XXX001", "P01", "LAST", "FBCVA", 2,
    "XXX001", "P01", "LAST", "SBCVALOG", -7,
    "XXX001", "P02", "LAST", "SBCVA", -13,
    "XXX001", "P02", "LAST", "FBCVA", 5,
    "XXX001", "P02", "LAST", "SBCVALOG", 12,
    "XXX001", "P03", "LAST", "SBCVA", NA,
    "XXX001", "P03", "LAST", "FBCVA", 17
  )

  expected_output1 <- tibble::tribble(
    ~STUDYID, ~USUBJID, ~BASETYPE, ~PARAMCD, ~CHG, ~CRIT1, ~CRIT1FL, ~CRIT2,
    ~CRIT2FL, ~CRIT3, ~CRIT3FL, ~CRIT4, ~CRIT4FL,
    "XXX001", "P01", "LAST", "SBCVA", 0, "0 <= CHG <= 5", "Y", "CHG <= -3",
    "N", "CHG <= 10", "Y", "CHG >= 8", "N",
    "XXX001", "P01", "LAST", "FBCVA", 2, "0 <= CHG <= 5", "Y", "CHG <= -3",
    "N", "CHG <= 10", "Y", "CHG >= 8", "N",
    "XXX001", "P02", "LAST", "SBCVA", -13, "0 <= CHG <= 5", "N", "CHG <= -3",
    "Y", "CHG <= 10", "Y", "CHG >= 8", "N",
    "XXX001", "P02", "LAST", "FBCVA", 5, "0 <= CHG <= 5", "Y", "CHG <= -3",
    "N", "CHG <= 10", "Y", "CHG >= 8", "N",
    "XXX001", "P03", "LAST", "SBCVA", NA, "0 <= CHG <= 5", NA, "CHG <= -3",
    NA, "CHG <= 10", NA, "CHG >= 8", NA,
    "XXX001", "P03", "LAST", "FBCVA", 17, "0 <= CHG <= 5", "N", "CHG <= -3",
    "N", "CHG <= 10", "N", "CHG >= 8", "Y",
    "XXX001", "P01", "LAST", "SBCVALOG", -7, NA, NA, NA, NA, NA, NA, NA, NA,
    "XXX001", "P02", "LAST", "SBCVALOG", 12, NA, NA, NA, NA, NA, NA, NA, NA
  )

  actual_output1 <- derive_var_bcvacritxfl(
    dataset_adbcva = input1,
    paramcds = c("SBCVA", "FBCVA"),
    basetype = NULL,
    bcva_ranges = list(c(0, 5)),
    bcva_uplims = list(-3, 10),
    bcva_lowlims = list(8),
    additional_text = ""
  )

  expected_output2 <- tibble::tribble(
    ~STUDYID, ~USUBJID, ~BASETYPE, ~PARAMCD, ~CHG, ~CRIT2, ~CRIT2FL,
    "XXX001", "P01", "LAST", "SBCVA", 0,
    "-2 <= CHG <= 2 (Relative to Baseline)", "Y",
    "XXX001", "P01", "LAST", "FBCVA", 2,
    "-2 <= CHG <= 2 (Relative to Baseline)", "Y",
    "XXX001", "P02", "LAST", "SBCVA", -13,
    "-2 <= CHG <= 2 (Relative to Baseline)", "N",
    "XXX001", "P02", "LAST", "FBCVA", 5,
    "-2 <= CHG <= 2 (Relative to Baseline)", "N",
    "XXX001", "P03", "LAST", "SBCVA", NA,
    "-2 <= CHG <= 2 (Relative to Baseline)", NA,
    "XXX001", "P03", "LAST", "FBCVA", 17,
    "-2 <= CHG <= 2 (Relative to Baseline)", "N",
    "XXX001", "P01", "LAST", "SBCVALOG", -7,
    NA, NA,
    "XXX001", "P02", "LAST", "SBCVALOG", 12,
    NA, NA
  )

  actual_output2 <- derive_var_bcvacritxfl(
    dataset_adbcva = input1,
    paramcds = c("SBCVA", "FBCVA"),
    basetype = NULL,
    bcva_ranges = list(c(-2, 2)),
    critxfl_index = 2,
    additional_text = " (Relative to Baseline)"
  )

  input2 <- tibble::tribble(
    ~STUDYID, ~USUBJID, ~AVISIT, ~BASETYPE, ~PARAMCD,
    ~AVAL, ~CHG, ~CRIT1, ~CRIT1FL,
    "XXX001", "P01", "BASELINE", "LAST", "SBCVA", 4,
    NA, "CHG <= 0", NA,
    "XXX001", "P01", "BASELINE", "LAST", "SBCVA", 6,
    NA, "CHG <= 0", NA,
    "XXX001", "P01", "AVERAGE BASELINE", "AVERAGE",
    "SBCVA", 5, NA, "CHG <= 0", NA,
    "XXX001", "P01", "WEEK 2", "LAST", "SBCVA", -3,
    NA, "CHG <= 0", "N",
    "XXX001", "P01", "WEEK 4", "LAST", "SBCVA", -10,
    NA, "CHG <= 0", "N",
    "XXX001", "P01", "WEEK 6", "LAST", "SBCVA", 12,
    NA, "CHG <= 0", "Y",
    "XXX001", "P01", "WEEK 2", "AVERAGE", "SBCVA", -2,
    -7, "CHG <= 0", "N",
    "XXX001", "P01", "WEEK 4", "AVERAGE", "SBCVA", 6,
    1, "CHG <= 0", "Y",
    "XXX001", "P01", "WEEK 6", "AVERAGE", "SBCVA", 3,
    -2, "CHG <= 0", "N"
  )

  expected_output3 <- tibble::tribble(
    ~STUDYID, ~USUBJID, ~AVISIT, ~BASETYPE, ~PARAMCD, ~AVAL,
    ~CHG, ~CRIT1, ~CRIT1FL, ~CRIT2, ~CRIT2FL,
    "XXX001", "P01", "AVERAGE BASELINE", "AVERAGE", "SBCVA",
    5, NA, "CHG <= 0", NA, "CHG >= 1 (AVERAGE)", NA,
    "XXX001", "P01", "WEEK 2", "AVERAGE", "SBCVA", -2, -7,
    "CHG <= 0", "N", "CHG >= 1 (AVERAGE)", "N",
    "XXX001", "P01", "WEEK 4", "AVERAGE", "SBCVA", 6, 1,
    "CHG <= 0", "Y", "CHG >= 1 (AVERAGE)", "Y",
    "XXX001", "P01", "WEEK 6", "AVERAGE", "SBCVA", 3, -2,
    "CHG <= 0", "N", "CHG >= 1 (AVERAGE)", "N",
    "XXX001", "P01", "BASELINE", "LAST", "SBCVA", 4, NA,
    "CHG <= 0", NA, NA, NA,
    "XXX001", "P01", "BASELINE", "LAST", "SBCVA", 6, NA,
    "CHG <= 0", NA, NA, NA,
    "XXX001", "P01", "WEEK 2", "LAST", "SBCVA", -3, NA,
    "CHG <= 0", "N", NA, NA,
    "XXX001", "P01", "WEEK 4", "LAST", "SBCVA", -10, NA,
    "CHG <= 0", "N", NA, NA,
    "XXX001", "P01", "WEEK 6", "LAST", "SBCVA", 12, NA,
    "CHG <= 0", "Y", NA, NA
  )

  actual_output3 <- derive_var_bcvacritxfl(
    dataset_adbcva = input2,
    paramcds = c("SBCVA", "FBCVA"),
    basetype = "AVERAGE",
    bcva_lowlims = list(1),
    additional_text = " (AVERAGE)"
  )

  expect_equal(
    actual_output1,
    expected_output1,
  )

  expect_equal(
    actual_output2,
    expected_output2,
  )

  expect_equal(
    actual_output3,
    expected_output3,
  )
})
