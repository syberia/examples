read <- function(name) {
  if (project$cache_exists(name)) {
    message("Reading from cache...")
    project$cache_get(name)
  } else {
    temp <- tempfile(); on.exit(unlink(temp))
    message("reading into memory...")
    download.file(name, temp, method = "curl")
    data <- readr::read_csv(utils::unzip(temp), col_names = FALSE)
    project$cache_set(name, data)
    data
  }
}

write <- function(df) stop("Cannot write to a URL, aborting")
