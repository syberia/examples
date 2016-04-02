# Imagine that a "gender" variable has four unique
# values: M, F, Male, and Female (and potentially case
# sensitivity differences). This mungebit will replace
# such a column with a single categorical M or F.
train <- predict <- column_transformation(function(column) {
  column <- tolower(column)
  factor(levels = c('M', 'F'),
    ifelse(column == 'm' | column == 'male', 'M',
      ifelse(column == 'f' | column == 'female', 'F', NA_character_)))
})

