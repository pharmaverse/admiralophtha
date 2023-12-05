## Test 1: Criterion flags derived correctly ----
test_that("derive_var_bcvacritxfl Test 1: Criterion flags derived correctly", {
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

  expect_equal(
    actual_output1,
    expected_output1,
  )

})

## Test 2: Correct appending in CRITx of additional text ----
test_that("derive_var_bcvacritxfl Test 2: Correct appending in CRITx of additional text", {

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
    actual_output2,
    expected_output2,
  )
})


## Test 3: Correct CRITx index when critxfl_index not supplied ----
test_that("derive_var_bcvacritxfl Test 3: Correct CRITx index when critxfl_index not supplied", {

  expected_output3 <- tibble::tribble(
    ~STUDYID, ~USUBJID, ~AVAL, ~CHG, ~CRIT1, ~CRIT1FL, ~CRIT2, ~CRIT2FL,
    "XXX001", "P01", 6, 3, "4 <= AVAL <= 7", "Y", "AVAL >= 5", "Y",
    "XXX001", "P01", 1, 4, "4 <= AVAL <= 7", "N", "AVAL >= 5", "N",
    "XXX001", "P02", 8, 1, "4 <= AVAL <= 7", "N", "AVAL >= 5", "Y",
    "XXX001", "P02", 5, 3, "4 <= AVAL <= 7", "Y", "AVAL >= 5", "Y",
    "XXX001", "P03", NA, NA, "4 <= AVAL <= 7", NA, "AVAL >= 5", NA,
    "XXX001", "P03", 0, 2, "4 <= AVAL <= 7", "N", "AVAL >= 5", "N"
  )

  actual_output3 <- derive_var_bcvacritxfl(
    dataset = expected_output3 %>% select(-starts_with("CRIT2")),
    crit_var = exprs(AVAL),
    bcva_lowlims = list(c(5))
  )

  expect_equal(
    actual_output3,
    expected_output3,
  )
})

## Test 4: Correct CRITx index when critxfl_index is supplied ----
test_that("derive_var_bcvacritxfl Test 4: Correct CRITx index when critxfl_index is supplied", {

  expected_output4 <- tibble::tribble(
    ~STUDYID, ~USUBJID, ~AVAL, ~CHG, ~CRIT12, ~CRIT12FL,
    "XXX001", "P01", 6, 3, "AVAL <= 1", "N",
    "XXX001", "P01", 1, 4, "AVAL <= 1", "Y",
    "XXX001", "P02", 8, 1, "AVAL <= 1", "N",
    "XXX001", "P02", 5, 3, "AVAL <= 1", "N",
    "XXX001", "P03", NA, NA, "AVAL <= 1", NA,
    "XXX001", "P03", 0, 2, "AVAL <= 1", "Y"
  )

  actual_output4 <- derive_var_bcvacritxfl(
    dataset = expected_output4 %>% select(-starts_with("CRIT2")),
    crit_var = exprs(AVAL),
    bcva_uplims = list(c(1)),
    critxfl_index = 12
  )

  expect_equal(
    actual_output4,
    expected_output4,
  )
})
