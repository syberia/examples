# Apply base::transform with the given expression. For example, calling with
#
# mungebit$run(data, alist(foo = bar * baz, bmi = weight / height ^ 2))
#
# will be equivalent to
#
# data <- within(data, foo <- bar * baz, bmi <- weight / height ^ 2)
train <- predict <- function(data, maps) {
  do.call(transform, c(list(`_data` = data), maps))
}

