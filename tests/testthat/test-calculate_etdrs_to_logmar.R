test_that("ETDRS converted correctly", {
  input <- c(5, 10, 15, 20, 25, 30, 90)

  expected_output <- c(1.6, 1.5, 1.4, 1.3, 1.2, 1.1, -0.1)
  actual_output <- calculate_etdrs_to_logmar(input)

  expect_equal(
    actual_output,
    expected_output,
  )
})
