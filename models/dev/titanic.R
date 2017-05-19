titles <- c(
  mr = "Mr.", ms = "Mrs.", mrs = "Ms\\.|Miss\\.",
  master = "Master.", rev = "Rev.", dr = "Dr."
)
fixed_titles <- c("mr", "ms", "master", "rev", "dr")

tickets <- c(
  pc = "PC", a = "A/", sc = "S.C.", ca = "C\\.A|CA",
  sp = "SP|S\\.P", w = "W", soc = "SOC|S\\.O\\.C", ston = "SOTON|STON",
  line = "LINE", paris = "PARIS"
)
fixed_tickets <- c("pc", "a", "sc", "w", "line", "paris")

cabin_derivations <- alist(
  cabin_number    = as.integer(gsub("[^0-9]+", "", cabin)),
  cabin_letter    = factor(gsub("[^a-zA-Z]+", "", cabin)),
  cabin_fare      = stats::ave(title_fare, cabin, FUN = mean)
)
syberia_project()$cache_set("titanic_model", tempfile(fileext = ".rds"))

list(
  import = list(
    url = list(
      "https://raw.githubusercontent.com/haven-jeon/introduction_to_most_usable_pkgs_in_project/master/bicdata/data/titanic.csv",
      stringsAsFactors = FALSE
    )
  ),

  data = list(
    "has paren in name"       = list(multi_column_transformation(function(name) grepl("(", fixed = TRUE, name)), "name", "has_paren")
   ,"Name length variable"    = list(new_variable, function(name) nchar(name), "name_length")
   ,"Formal title"            = list(regex_factor, "name", "title", cases = titles, fixed = fixed_titles)
   ,"Ticket type"             = list(regex_factor, "ticket", "ticket_type", cases = tickets, fixed = fixed_tickets)
   ,"title_fare variable"     = list(new_variable, function(title, fare) { stats::ave(fare, title, FUN = mean) }, "title_fare")
   ,"class_fare"              = list(multi_column_transformation(function(klass, fare) { ave(fare, klass, FUN = mean) }), c("pclass", "fare"), "class_fare")
   ,"Some simple derivations" = list(atransform, alist(fare_diff = fare - title_fare, fare_pct = fare / title_fare, fare_diff_class = fare - class_fare, fare_pct_class = fare / class_fare))
   ,"Derived cabin variables" = list(atransform, cabin_derivations)
   ,"Cabin diff and pct"      = list(atransform, alist(fare_diff_cabin = fare - cabin_fare, fare_pct_cabin = fare / cabin_fare))
   ,"cabin_single_letter"     = list(new_variable, function(cabin_letter) factor(gsub("^(.).*$", "\\1", cabin_letter)), "cabin_single_letter")
   ,"Set factors"             = list(!factor, c("sex", "embarked"))
   ,"Logical to factor"       = list(!as.factor, is.logical)
   ,"Drop character vars"     = list(drop_variables, is.character)
   ,"Restore levels"          = list(restore_categorical_variables, is.factor)
   ,"Rename dep_var"          = list(renamer, c("survived" = "dep_var"))
  ),

  model = list('gbm'
    , .id_var             = 'X'
    , distribution        = 'bernoulli'
    , number_of_trees     = 100  # Set to 3000 for better model.
    , shrinkage_factor    = 0.05 # Set to 0.005 for better model.
    , depth               = 5
    , min_observations    = 6
    , train_fraction      = 1
    , bag_fraction        = 0.5
    , cv                  = FALSE # Uncomment lines below for cv.
  # , cv_folds            = 5 # For CV and/or > 1 cores need GBM globally installed.
  # , number_of_cores     = 1
    , perf_method         = 'OOB'
    , prediction_type     = 'response'
  ),

  export = list(
    R    = "titanic",
    # Change to fixed file like ~/tmp/model.rds
    file = syberia_project()$cache_get("titanic_model")
  )
)

