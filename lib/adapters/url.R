read <- function(options) {
  if (is.list(options)) {
    name <- options[[1]]
    options <- options[-1]
  } else {
    name <- options
    options <- list()
  }

  options$text <- RCurl::getURL(name)
  do.call(utils::read.csv, options)
}

write <- function(...) {
  stop("Cannot write to a URL, aborting")
}

