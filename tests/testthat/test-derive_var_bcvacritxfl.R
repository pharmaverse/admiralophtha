## Test 1: Correct deprecation message for derive_var_bcvacritxfl_util ----
test_that("derive_var_bcvacritxfl_util Test 1: Correct deprecation message for derive_var_bcvacritxfl_util", {
  expect_snapshot(
    error = TRUE,
    derive_var_bcvacritxfl_util(
      dataset = iris,
      crit_var = exprs(AVAL)
    )
  )

})

## Test 2: Correct deprecation message for derive_var_bcvacritxfl ----
test_that("derive_var_bcvacritxfl Test 2: Correct deprecation message for derive_var_bcvacritxfl", {
  expect_snapshot(
    error = TRUE,
    derive_var_bcvacritxfl(
      dataset = iris,
      crit_var = exprs(AVAL),
      bcva_uplims = list(c(1)),
      critxfl_index = 12
    )
  )
})
