read <- function(name) {
  if (director$cache$exists(name$resource)) {
    message('Reading from cache...')
    director$cache$get(name$resource)
  } else {
    temp <- tempfile(); on.exit(unlink(temp))
    contents <- gsub('.zip$', '', tail(str_split(name$resource, '/')[[1]], 1))
    download.file(name$resource, temp, method = 'curl')
    message('reading into memory...')
    data <- read_csv(unz(temp, contents), col_names = FALSE)
    director$cache$set(name$resource, data)
    data
  }
}

write <- function(df) stop('Cannot write to a URL, aborting')
