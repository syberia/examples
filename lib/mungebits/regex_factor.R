# This mungebit converts a list of presumably independent regex
# matches to a categorical feature. For example, if
#
# cases = c(foo = "^foo", bar = "^bar", baz = "baz$")
#
# then applying this to c("food", "barfood", "books", "goombaz")
# will yield c("foo", "bar", "other", "baz") as a categorical feature
# with levels c("foo", "bar", "baz", "other").
train <- predict <-
  function(data, feature_name, derived_name, cases, other = "other", fixed = character(0)) {
    feature <- data[[feature_name]]
    if (!is.character(feature)) {
      stop("The feature ", sQuote(feature_name), " must be of type character ",
           "when used with the regex_factor mungebit.")
    }

    x <- Reduce(function(labels, case) {
      ifelse(grepl(case, feature, fixed = names(case) %in% fixed),
             names(case), labels)
    }, Map(`names<-`, cases, names(cases)), character(length(feature)))
    x[!nzchar(x)] <- other
    data[[derived_name]] <- factor(x, c(names(cases), other))
    data
  }


