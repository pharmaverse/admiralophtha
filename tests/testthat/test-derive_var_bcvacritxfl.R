test_that("Criterion flags derived correctly", {

  expected_output1 <- tibble::tribble(
    ~STUDYID, ~USUBJID, ~CHG, ~CRIT1, ~CRIT1FL, ~CRIT2,
    ~CRIT2FL, ~CRIT3, ~CRIT3FL, ~CRIT4, ~CRIT4FL,
    "XXX001", "P01", 0, "0 <= CHG <= 5", "Y", "CHG <= -3",
    "N", "CHG <= 10", "Y", "CHG >= 8", "N",
    "XXX001", "P01", 2, "0 <= CHG <= 5", "Y", "CHG <= -3",
    "N", "CHG <= 10", "Y", "CHG >= 8", "N",
    "XXX001", "P02", -13, "0 <= CHG <= 5", "N", "CHG <= -3",
    "Y", "CHG <= 10", "Y", "CHG >= 8", "N",
    "XXX001", "P02", 5, "0 <= CHG <= 5", "Y", "CHG <= -3",
    "N", "CHG <= 10", "Y", "CHG >= 8", "N",
    "XXX001", "P03", NA, "0 <= CHG <= 5", NA, "CHG <= -3",
    NA, "CHG <= 10", NA, "CHG >= 8", NA,
    "XXX001", "P03", 17, "0 <= CHG <= 5", "N", "CHG <= -3",
    "N", "CHG <= 10", "N", "CHG >= 8", "Y"
  )

  actual_output1 <- derive_var_bcvacritxfl(
    dataset = expected_output1 %>% select(-starts_with("CRIT")),
    crit_var = exprs(CHG),
    bcva_ranges = list(c(0, 5)),
    bcva_uplims = list(-3, 10),
    bcva_lowlims = list(8),
    additional_text = ""
  )

  expected_output2 <- tibble::tribble(
    ~STUDYID, ~USUBJID, ~AVAL, ~CHG, ~CRIT1, ~CRIT1FL,
    "XXX001", "P01", 6, 3, "4 <= AVAL <= 7 (transformed)", "Y",
    "XXX001", "P01", 1, 4, "4 <= AVAL <= 7 (transformed)", "N",
    "XXX001", "P02", 8, 1, "4 <= AVAL <= 7 (transformed)", "N",
    "XXX001", "P02", 5, 3, "4 <= AVAL <= 7 (transformed)", "Y",
    "XXX001", "P03", NA, NA, "4 <= AVAL <= 7 (transformed)", NA,
    "XXX001", "P03", 0, 2, "4 <= AVAL <= 7 (transformed)", "N"
  )

  actual_output2 <- derive_var_bcvacritxfl(
    dataset = expected_output2 %>% select(-starts_with("CRIT")),
    crit_var = exprs(AVAL),
    bcva_ranges = list(c(4, 7)),
    additional_text = " (transformed)"
  )

  expect_equal(
    actual_output1,
    expected_output1,
  )

  expect_equal(
    actual_output2,
    expected_output2,
  )

})
