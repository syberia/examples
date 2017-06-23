# Match factor variables given data dictionaries.
train <- function(data, variables, files) {
  match <- function(column, file) {
    legend <- read.csv(file)[1:2]
    legend[base::match(column, legend[[1]]), 2]
  }

  for (i in seq_along(variables)) {
    data[[variables[i]]] <- factor(match(data[[variables[i]]], files[i]))
  }

  data
}

