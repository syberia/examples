# An example of a logistic regression model based off Kaggle's Titanic data set.
# https://www.kaggle.com/c/titanic 

# Let's define some constants we will use below later.
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
# This is just so we have a temporary file to save our model to. 
# At the bottom of this file, you can replace it with a static CSV path.
syberia_project()$cache_set("titanic_model", tempfile(fileext = ".rds"))


# A syberia model file is a nested list structure. Top-level lists are called
# stages. You can create your own stages by writing `lib/stages/my_stage.R`.
# A stage should return a [stagerunner](github.com/syberia/stagerunner) object.
list(
  import = list(
    url = list(
      "https://raw.githubusercontent.com/haven-jeon/introduction_to_most_usable_pkgs_in_project/master/bicdata/data/titanic.csv",
      stringsAsFactors = FALSE
    )
  ),


  # Data stage is a perfect place to transform your dataset prior to modeling
  # The default data stage defines a DSL for creating and training
  # [mungebits](github.com/syberia/mungebits)
  # Yes, you need to train your data preparation!
  # Traditionally data scientists have been preparing models and shipping them to
  # engineers that would reimplement them in Java or another traditional server language.
  # This is a very slow and extremely error-prone process.
  #
  # Also, there is one more important consideration: data preparation should
  # operate differently in train versus predict!
  # For example, let's say that we want to impute a missing variable using column mean.
  # In training, you'd want to use the mean calculated from the import stage dataframe.
  # However, in production you do not have access to the input dataframe anymore!
  # So you need to store the imputed mean somewhere and use that number in production.
  # Data stage takes care of this duality, allowing you to use a plethora of mungebits
  # from [syberiaMungebits](github.com/syberia/syberiaMungebits). Or you can write your own
  # and put them in `lib/mungebits/my_mungebit.R`
  data = list(
    "has paren in name"       = list(multi_column_transformation(function(name) grepl("(", fixed = TRUE, name)), "name", "has_paren")
   ,"Name length variable"    = list(new_variable, function(name) nchar(name), "name_length")
   ,"Formal title"            = list(regex_factor, "name", "title", cases = titles, fixed = fixed_titles)
   ,"Ticket type"             = list(regex_factor, "ticket", "ticket_type", cases = tickets, fixed = fixed_tickets)
   ,"title_fare variable"     = list(new_variable, function(title, fare) { stats::ave(fare, title, FUN = mean) }, "title_fare")
   ,"class_fare"              = list(multi_column_transformation(function(klass, fare) { stats::ave(fare, klass, FUN = mean) }), c("pclass", "fare"), "class_fare")
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

  # Once the data is prepared and is in the right format we are ready to
  # do the modeling itself.
  # You can use any R package to create a *classifier*.
  # Classifiers are determined by the `train` and `predict` functions.
  # The output of the model stage is a [tundraContainer](github.com/syberia/tundra)
  # A tundracontainer is an object that contains all the information necessary
  # to make a prediction: the munge procedure, the classifier object, as well as
  # the ids of the variables that were in training. This helps to ensure that
  # you are not predicting on the same ids that you used for training,
  # helping you make a more accurate validation. You can set `.is_var` to the id column name
  # or it will default to 'id'.
  # The most interesting part about a tundracontainer is its predict function.
  # The predict function first runs all the mungebits in predict mode,
  # then it checks that you are not predicting on train ids, and then calls the
  # classifier predict method, like `predict.gbm`
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


  # When all is said and done you need to export the result of your hard work.
  # This stage uses the same adapters as the *import* stage.
  # If you need to export to a custom place you need to write a new adapter and
  # implement the `write` function.
  export = list(
    R    = "titanic",
    # Change to fixed file like ~/tmp/model.rds
    file = syberia_project()$cache_get("titanic_model")
  )
)

