read <- function(name) {
  utils::read.csv(text = RCurl::getURL(name))
}

write <- function(df) stop('Cannot write to a URL, aborting')
