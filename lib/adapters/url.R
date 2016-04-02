read <- function(name) {
  read.csv(text = RCurl::getURL(name))
}

write <- function(df) stop('Cannot write to a URL, aborting')
