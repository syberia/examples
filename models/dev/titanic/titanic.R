# A trivial titanic regression model

# A syberia model file is a nested list structure. Top-level lists are called
# stages. You can create your own stages by writing `lib/stages/my_stage.R`.
# A stage should return a [stagerunner](github.com/robertzk/stagerunner) object.

list(
  # Titanic dataset is fairly popular. Here we're downloading it from a public github repo
  import = list(
    # File, R and s3 adapters ship by default. If you want to make a different adapter
    # you can define one by writing `lib/adapters/my_adapter.R`. Here we have made
    # a custom URL adapter
    url = 'https://raw.githubusercontent.com/haven-jeon/introduction_to_most_usable_pkgs_in_project/master/bicdata/data/titanic.csv'
  ),

  # Data stage is a perfect place to transform your dataset prior to modeling
  # The default data stage defines a DSL for creating and training
  # [mungebits](github.com/robertzk/mungebits)
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
  # from [syberiaMungebits](github.com/robertzk/syberiaMungebits). Or you can write your own
  # and put them in `lib/mungebits/my_mungebit.R`
  data = list(
    # The left-hand side defines the informal name of a mungebit that you will see
    # when you run this model.
    # The right-hand side is the mungebit invocation.
    "Factor to character"   = list(column_transformation(as.character), is.factor)

    # Both `column_transformation` and `multi_column_transformation` come from [syberiaMungebits] package
    # This particular mungebit creates a new variable - *name_length*
    ,"Name length variable" = list(multi_column_transformation(function(name) nchar(name)), "name", "name_length")
    ,"has paren in name"    = list(multi_column_transformation(function(name) grepl("(", fixed = TRUE, name)), "name", "has_paren")
    ,"mr indicator"         = list(multi_column_transformation(function(name) grepl("Mr.", fixed = TRUE, name)), "name", "is_mister")
    ,"mrs indicator"        = list(multi_column_transformation(function(name) grepl("Mrs.", fixed = TRUE, name)), "name", "is_missus")
    ,"ms indicator"         = list(multi_column_transformation(function(name) grepl("Ms\\.|Miss\\.", name)), "name", "is_miss")
    ,"master indicator"     = list(multi_column_transformation(function(name) grepl("Master.", fixed = TRUE, name)), "name", "is_master")
    ,"rev indicator"        = list(multi_column_transformation(function(name) grepl("Rev.", fixed = TRUE, name)), "name", "is_rev")
    ,"dr indicator"         = list(multi_column_transformation(function(name) grepl("Dr.", fixed = TRUE, name)), "name", "is_dr")

    # Sometimes it's easy to write a mungebit by just in-lining an existing component.
    # However sometimes you do need to perform some non-trivial logic. In this case you can
    # write a new mungebit. This one comes from `lib/mungebits/title_factor.R`
    ,"title"                = list(title_factor)
    ,"fare_title"           = list(multi_column_transformation(function(title, fare) { ave(fare, title, FUN = mean) }), c("title", "fare"), "title_fare")
    ,"fare_diff"            = list(multi_column_transformation(`-`), c("fare", "title_fare"), "fare_diff")
    ,"fare_pct"             = list(multi_column_transformation(`/`), c("fare", "title_fare"), "fare_pct")
    ,"fare_class"           = list(multi_column_transformation(function(klass, fare) { ave(fare, klass, FUN = mean) }), c("pclass", "fare"), "class_fare")
    ,"fare_diff_class"      = list(multi_column_transformation(`-`), c("fare", "class_fare"), "fare_diff_class")
    ,"fare_pct_class"       = list(multi_column_transformation(`/`), c("fare", "class_fare"), "fare_pct_class")
    ,"cabin_number"         = list(multi_column_transformation(function(cabin) as.integer(gsub("[^0-9]+", "", cabin))), "cabin", "cabin_number")
    ,"cabin_letter"         = list(multi_column_transformation(function(cabin) factor(gsub("[^a-zA-Z]+", "", cabin))), "cabin", "cabin_letter")
    ,"cabin_single_letter"  = list(multi_column_transformation(function(cabin) factor(gsub("^(.).*$", "\\1", cabin))), "cabin_letter", "cabin_single_letter")
    ,"fare_cabin"           = list(multi_column_transformation(function(title, fare) { ave(fare, title, FUN = mean) }), c("cabin_single_letter", "fare"), "cabin_fare")
    ,"fare_diff_cabin"      = list(multi_column_transformation(`-`), c("fare", "cabin_fare"), "fare_diff_cabin")
    ,"fare_pct_cabin"       = list(multi_column_transformation(`/`), c("fare", "cabin_fare"), "fare_pct_cabin")

    ,"PC ticket"            = list(multi_column_transformation(function(name) grepl("PC ", fixed = TRUE, name)), "ticket", "has_pc_ticket")
    ,"A  ticket"            = list(multi_column_transformation(function(name) grepl("A/", fixed = TRUE, name)), "ticket", "has_a_ticket")
    ,"SC ticket"            = list(multi_column_transformation(function(name) grepl("S.C.", fixed = TRUE, name)), "ticket", "has_sc_ticket")
    ,"CA ticket"            = list(multi_column_transformation(function(name) grepl("C.A", fixed = TRUE, name)), "ticket", "has_ca_ticket")
    ,"CA ticket"            = list(multi_column_transformation(function(name) grepl("C\\.A|CA", name)), "ticket", "has_ca_ticket")
    ,"SP ticket"            = list(multi_column_transformation(function(name) grepl("SP|S\\.P", name)), "ticket", "has_sp_ticket")
    ,"W  ticket"            = list(multi_column_transformation(function(name) grepl("W", name)), "ticket", "has_w_ticket")
    ,"SOC ticket"           = list(multi_column_transformation(function(name) grepl("SOC|S\\.O\\.C", name)), "ticket", "has_soc_ticket")
    ,"STON ticket"          = list(multi_column_transformation(function(name) grepl("SOTON|STON", name)), "ticket", "has_ston_ticket")
    ,"LINE ticket"          = list(multi_column_transformation(function(name) grepl("LINE", fixed = TRUE, name)), "ticket", "has_ston_ticket")
    ,"PARIS ticket"         = list(multi_column_transformation(function(name) grepl("PARIS", fixed = TRUE, name)), "ticket", "has_paris_ticket")

    ,"Set factors"          = list(column_transformation(factor), c("sex", "embarked"))
    ,"Logical to factor"    = list(column_transformation(as.factor), is.logical)
    ,"Drop character vars"  = list(drop_variables, is.character)
    ,"Restore levels"       = list(restore_categorical_variables)
    ,"Rename dep_var"       = list(renamer, c("survived" = "dep_var"))
  ),

  # Once the data is prepared and is in the right format we are ready to
  # do the modeling itself.
  # You can use any R package to create a *classifier*. It may be a poor name
  # choice, since you can create not only classification models, but it
  # got stuck.
  # Classifiers are determined by the `train` and `predict` functions.
  # The output of the model stage is a [tundraContainer](github.com/robertzk/tundra)
  # A tundracontainer is an object that contains all the information necessary
  # to make a prediction: the munge procedure, the classifier object, as well as
  # the ids of the variables that were in training. This helps to ensure that
  # you are not predicting on the same ids that you used for training,
  # helping you make a more accurate validation. You can set `.is_var` to the id column name
  # or it will default to 'id'.
  # The most interesting part about a tundracontainer is it's predict function.
  # The predict function first runs all the mungebits in predict mode,
  # then it checks that you are not predicting on train ids, and then calls the
  # classifier predict method, like `predict.gbm`
  model = list('gbm'
    , .id_var             = 'X'
    , distribution        = 'bernoulli'
    , number_of_trees     = 3000
    , shrinkage_factor    = 0.005
    , depth               = 5
    , min_observations    = 6
    , train_fraction      = 1
    , bag_fraction        = 0.5
    , cv                  = TRUE
    , cv_folds            = 5
    , number_of_cores     = 4
    , perf_method         = 'cv'
    , prediction_type     = 'response'
  ),

  # When all is said and done you need to export the result of your hard work.
  # This stage uses the same adapters as the *import* stage.
  # If you need to export to a custom place you need to write a new adapter and
  # implement the `write` function.
  export = list(
    s3 = 'syberia/titanic/gbm',
    R  = 'titanic'
  )
)
