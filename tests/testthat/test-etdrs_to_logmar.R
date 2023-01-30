test_that("ETDRS converted correctly", {
  input <- data.frame(AVAL = c(5, 10, 15, 20, 25, 30, 90))

  expected_output <- data.frame(AVAL = c(1.6, 1.5, 1.4, 1.3, 1.2, 1.1, -0.1))
  actual_output <- etdrs_to_logmar(input)

  expect_equal(
    actual_output$AVAL,
    expected_output$AVAL,
  )
})
