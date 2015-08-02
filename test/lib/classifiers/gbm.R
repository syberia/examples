test_that("it can only take numeric number_of_trees", {
  mock_gbm  <- resource()(default_args = list(
    number_of_trees = "explode",
    cv = TRUE,
    distribution = "bernoulli",
    min_observations = 1,
    train_fraction = 1,
    bag_fraction = 0.05
    )
  )
  mock_data <- iris
  mock_data$dep_var <- rep(1, NROW(iris))
  expect_error(mock_gbm$train(mock_data))
})
