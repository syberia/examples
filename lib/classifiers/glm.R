# This function will be called to train the model
train <- function(dataframe) {
  args <- list()
  args[[1]] = as.formula(input$formula)
  args$data <- dataframe
  args$family = binomial(logit)

  output <<- list(model=do.call(glm, args))
}

# This function will be called on the created model to make the prediction
predict <- function(dataframe) {
  predict(output$model, newdata=dataframe)
}
