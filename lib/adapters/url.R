read <- function(name) {
  readr::read_csv(text = RCurl::getURL(name))
}

write <- function(df) stop('Cannot write to a URL, aborting')
