test_that("it returns a prediction", {
  mock_model <- resource()()
  mock_model$train(iris)
  expect_equal(length(mock_model$predict(iris)), NROW(iris))
})
