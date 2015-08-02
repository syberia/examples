# The models preprocessor.
#
# Inject lexicals (convenient syntax shortcuts) and "output" helper.
preprocessor <- function(resource, director, source_args) {
  source_args$local$model_version <- version <- gsub("^[^/]+\\/[^/]+\\/", "", resource)
  source_args$local$model_name    <- basename(version)
  source_args$local$output <- 
    function(suffix = '', create = TRUE, dir = file.path(director$root(), 'tmp')) {
      filename <- file.path(dir, version, suffix)
      if (create && !file.exists(dir <- dirname(filename)))
        dir.create(dir, recursive = TRUE)
      filename
    }

  lexicals <- director$resource('lib/shared/lexicals')$value()
  for (x in ls(lexicals)) source_args$local[[x]] <- lexicals[[x]]

  # Add mungebits to local environment.
  mungebits <- lapply(mungebits_names <- director$find(base = 'lib/mungebits'),
    function(x) director$resource(x)$value())
  mungebits_names <- gsub('/', '.',
    sapply(mungebits_names, function(x) director:::strip_root('lib/mungebits', x)),
    fixed = TRUE)

  for (i in seq_along(mungebits))
    source_args$local[[mungebits_names[i]]] <- mungebits[[i]]

  source()
}

