## Test 1: AFEYE is derived correctly in all possible loc/lat combinations ----
test_that("derive_var_afeye Test 1: AFEYE is derived correctly in all possible loc/lat combinations", {

  expected_output1 <- tibble::tribble(
    ~STUDYID, ~USUBJID, ~STUDYEYE, ~OELOC, ~OELAT, ~AFEYE,
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

  actual_output1 <- expected_output1 %>%
    select(-AFEYE) %>%
    derive_var_afeye(
      loc_var = OELOC,
      lat_var = OELAT
    )

  expect_dfs_equal(
    actual_output1,
    expected_output1,
    keys = c("STUDYID", "USUBJID", "OELOC", "OELAT")
  )

})

## Test 2: AFEYE is derived correctly when parsing loc_vals ----
test_that("derive_var_afeye Test 2: AFEYE is derived correctly when parsing loc_vals", {

  expected_output2 <- tibble::tribble(
    ~STUDYID, ~USUBJID, ~STUDYEYE, ~AELOC, ~AELAT, ~AFEYE,
    "XXX001", "P01", "RIGHT", "EYES", "RIGHT", "Study Eye",
    "XXX001", "P01", "RIGHT", "RETINA", "LEFT", "Fellow Eye",
    "XXX001", "P01", "RIGHT", "", "", NA_character_,
  )

  actual_output2 <- expected_output2 %>%
    select(-AFEYE) %>%
    derive_var_afeye(
      loc_var = AELOC,
      lat_var = AELAT,
      loc_vals = c("EYES", "RETINA")
    )

  expect_dfs_equal(
    actual_output2,
    expected_output2,
    keys = c("STUDYID", "USUBJID", "AELOC", "AELAT")
  )
})

## Test 3: Deprecation of dataset_occ ----
test_that("derive_var_afeye Test 3: Deprecation of dataset_occ", {

  expected_output3 <- tibble::tribble(
    ~STUDYID, ~USUBJID, ~STUDYEYE, ~AELOC, ~AELAT, ~AFEYE,
    "XXX001", "P01", "RIGHT", "EYE", "RIGHT", "Study Eye",
    "XXX001", "P01", "RIGHT", "EYE", "LEFT", "Fellow Eye",
    "XXX001", "P01", "RIGHT", "", "", NA_character_,
  )

  expect_warning(
    actual_output3 <- expected_output3 %>%
      select(-AFEYE) %>%
      derive_var_afeye(
        dataset = NULL,
        dataset_occ = .,
        loc_var = AELOC,
        lat_var = AELAT
      ),
    class = "lifecycle_warning_deprecated"
  )

  expect_dfs_equal(
    actual_output3,
    expected_output3,
    keys = c("STUDYID", "USUBJID", "AELOC", "AELAT")
  )
})

## Test 4: Deprecation of lat_vals ----
test_that("derive_var_afeye Test 4: Deprecation of lat_vals", {

  expected_output4 <- tibble::tribble(
    ~STUDYID, ~USUBJID, ~STUDYEYE, ~AELOC, ~AELAT, ~AFEYE,
    "XXX001", "P01", "RIGHT", "EYE", "RIGHT", "Study Eye",
    "XXX001", "P01", "RIGHT", "EYE", "LEFT", "Fellow Eye",
    "XXX001", "P01", "RIGHT", "", "", NA_character_,
  )

  expect_warning(
    actual_output4 <- expected_output4 %>%
      select(-AFEYE) %>%
      derive_var_afeye(
        loc_var = AELOC,
        lat_var = AELAT,
        lat_vals = c("LEFT", "RIGHT", "BILATERAL")
      ),
    class = "lifecycle_warning_deprecated"
  )

  expect_dfs_equal(
    actual_output4,
    expected_output4,
    keys = c("STUDYID", "USUBJID", "AELOC", "AELAT")
  )
})
