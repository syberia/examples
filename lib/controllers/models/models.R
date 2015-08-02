# Use local = TRUE when sourcing construct_stage_runner in order to ensure
# objectdiff package is loaded for stageRunner creation (with tracked_environments).
construct_stage_runner <- define('construct_stage_runner', local = TRUE)[[1]](resource)

preprocessor <- define('preprocessor')[[1]]

# The models controller:
#
# Convert a model into a stagerunner.
function(args, resource, output, director) {
  require(objectdiff)
  message("Loading model: ", resource)

  tests <- file.path('test', resource)
  has_tests <- director$exists(tests)
  has_tests <- FALSE
  if (has_tests) {
    # TODO: (RK) Better sanity checking?
    testrunner <- stageRunner$new(new.env(), director$resource(tests)$value())
    testrunner$transform(function(fn) {
      library(testthat); force(fn)
      function(after) fn(cached_env, after)
    }) # TODO: (RK) Before/after only tests?
  }

  model_version <- gsub("^\\w+/", "", resource)
  if (!identical(resource, director$.cache$last_model)) {
    stagerunner <- construct_stage_runner(output, model_version)
  } else if (resource_object$any_dependencies_modified()) {
    message(director:::colourise("Copying cached environments...", "yellow"))
    stagerunner <- construct_stage_runner(output, model_version)
    stagerunner$coalesce(director$.cache$last_model_runner)
  } else if (!is.element('last_model_runner', names(director$.cache))) {
    stagerunner <- construct_stage_runner(output, model_version)
  } else {
    stagerunner <- director$.cache$last_model_runner
  }

  if (has_tests) stagerunner$overlay(testrunner, 'tests', flat = TRUE)

  director$.cache$last_model        <- resource
  director$.cache$last_model_runner <- stagerunner

  return(stagerunner)

  # TODO: (RK) Make new run helper that does these steps for a model resource.
  message("Running model: ", resource)

  args$verbose <- args$verbose %||% TRUE
  out <- tryCatch(error = function(e) e, do.call(stagerunner$run, args))

  if (inherits(out, 'simpleError'))
    stop(out$message)
  else {
    director$.cache$last_run <- out
    out
  }
}
