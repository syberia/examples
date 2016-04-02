train <- predict <- function(dataframe, replacements) {
  colnames(dataframe) <- Reduce(function(str, old_value) {
    str[colnames(dataframe) == old_value] <- replacements[[old_value]]
    str
  }, names(replacements), colnames(dataframe))
  dataframe
}

