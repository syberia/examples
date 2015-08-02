train <- function(dataframe) {
  cat("Training GBM model...\n")
  require(gbm)

  gbm_args <- list()
  indep_vars <- setdiff(colnames(dataframe), 'dep_var')
  stopifnot(length(indep_vars) > 0)

  if (input$cv) {
    gbm_args[[1]] <- as.formula(paste('dep_var ~ `',
                                      paste(indep_vars, collapse = "` + `"),
                                      '`', sep = ''))
    gbm_args$data <- dataframe
    gbm_args$cv.folds <- input$cv_folds
    gbm_args$n.cores  <- input$number_of_cores
  } else {
    gbm_args$x <- dataframe[, indep_vars]
    gbm_args$y <- dataframe[, 'dep_var']
  }

  gbm_args <- append(gbm_args,
    list(distribution      = input$distribution,
         n.trees           = input$number_of_trees,
         shrinkage         = input$shrinkage_factor,
         interaction.depth = input$depth,
         n.minobsinnode    = input$min_observations,
         train.fraction    = input$train_fraction,
         bag.fraction      = input$bag_fraction,
         verbose           = TRUE,
         keep.data         = TRUE
  ))
  if ('var.monotone' %in% names(input))
    gbm_args$var.monotone <- input$var.monotone

  # Hack to prevent a hellbug where the AWS.tools package
  # masks the stopCluster function, causing a problem in gbm training
  assign('stopCluster', parallel::stopCluster, envir = globalenv())
  output <<- list(model = do.call(gbm, gbm_args), perf = list())
  rm('stopCluster', envir = globalenv())

  if (!is.null(input$perf_method)) {
    output$perf[[input$perf_method]] <<-
      gbm.perf(output$model, method = input$perf_method, plot.it = FALSE)
  }
  if (!is.null(input$prediction_type))
    output$prediction_type <<- input$prediction_type

  invisible("gbm")
}

predict <- function(dataframe, predict_args = list()) {
  if (is.null(input$perf_method) && is.null(predict_args$perf_method))
    stop("No GBM performance method specified: must be OOB, test, or cv")

  require(gbm)

  type <- if (is.null(predict_args$prediction_type)) output$prediction_type
          else predict_args$prediction_type

  # Perf method specified, check if cached
  perf_method <- if (is.null(predict_args$perf_method)) input$perf_method
                 else predict_args$perf_method

  if (!perf_method %in% names(output$perf))
    output$perf[[perf_method]] <<-
      gbm.perf(output$model, method = perf_method, plot.it = FALSE)

  predict.gbm(object = output$model, newdata = dataframe,
    output$perf[[perf_method]], type = type)
}
