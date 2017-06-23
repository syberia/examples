train <- predict <- function(var, missing_level = "Missing") {
  browser()
  stopifnot(is.character(missing_level))
  if (!trained) {
    stopifnot(length(unique(var)) == 2)
  }

  if (is.character(var)) {
    var <- ifelse(nzchar(var) | is.na(var), missing_level, var)
  } else {
    var <- ifelse(is.na(var), missing_level, var)
  }
  factor(var, levels = c(Find(function(x) x == missing_level, var), missing_level))
}

#  browser()

