test_that("Logmar converted correctly", {
  input <- c(1.6, 1.5, 1.4, 1.3, 1.2, 1.1, -0.1)

  expected_output <- c(5, 10, 15, 20, 25, 30, 90)
  actual_output <- calculate_logmar_to_etdrs(input)

  expect_equal(
    actual_output,
    expected_output,
  )
})
