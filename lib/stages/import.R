# Import stage.

default_adapter <- resource('lib/shared/default_adapter')

#' Build a stagerunner for importing data with backup sources.
#'
#' @param import_options list. Nested list, one adapter per list entry.
#'   These adapter parametrizations will get converted to legitimate
#'   IO adapters. (See the "adapter" reference class.)
build_import_stagerunner <- function(import_options) {
  stages <- Reduce(append, lapply(seq_along(import_options), function(index) {
    adapter_name <- names(import_options)[index] %||% default_adapter
    adapter_name <- gsub('.', '/', adapter_name, fixed = TRUE)
    adapter <- resource(file.path('lib', 'adapters', adapter_name))
    opts <- import_options[[index]]

    if (is.function(adapter)) {
      # If a raw function, give it the import options and let it generate
      # the stage function. This is useful if you need finer control over
      # the importing process.
      setNames(list(adapter(opts)), adapter_name)
    } else {
      setNames(list(function(modelenv) {
        # Only run if data isn't already loaded
        if (!'data' %in% ls(modelenv)) {
          attempt <- suppressWarnings(suppressMessages(
            tryCatch(adapter$read(opts), error = function(e) FALSE)))
          if (!identical(attempt, FALSE) && !identical(attempt, NULL)) {
            modelenv$import_stage$adapter <- adapter
            modelenv$data <- attempt
          }
        }
      }), adapter$.keyword)
    }
  }))

  if (length(stages) > 0)
    names(stages) <- vapply(names(stages), function(stage_name)
      paste0("Import from ", gsub('/', '.', as.character(stage_name),
                                  fixed = TRUE)), character(1))

  # Always verify the data was loaded correctly in a separate stageRunner step.
  stages <- append(stages,
    list("(Internal) Verify data was loaded" = function(modelenv) {
      if (!'data' %in% ls(modelenv)) {
        stop("Failed to load data from all data sources", call. = FALSE)
      }

      modelenv$import_stage$env <-
        list2env(list(full_data = modelenv$data), parent = emptyenv())

      # TODO: (RK) Move this somewhere else.
      modelenv$import_stage$variable_summaries <-
        statsUtils::variable_summaries(modelenv$data)
    }))

  stages
}

function(import_options) {
  if (!is.list(import_options)) # Coerce to a list using the default adapter
    import_options <- setNames(list(resource = import_options), default_adapter)

  build_import_stagerunner(import_options)
}
