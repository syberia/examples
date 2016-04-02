# The simplest possible mungebit performs no operation.
train <- predict <- function(dataframe) {
  dataframe[[2]] <- dataframe[[2]] * 2
  dataframe
} 

