factorized_variables <- c("airconditioningtypeid", "architecturalstyletypeid", "buildingclasstypeid", "heatingorsystemtypeid", "propertylandusetypeid", "storytypeid", "typeconstructiontypeid") 
factor_legends <- file.path("~/Downloads/zillow_data_dictionary", c("AirConditioningTypeID-Table 1.csv", "ArchitecturalStyleTypeID-Table 1.csv", "BuildingClassTypeID-Table 1.csv", "HeatingOrSystemTypeID-Table 1.csv", "PropertyLandUseTypeID-Table 1.csv", "StoryTypeID-Table 1.csv", "TypeConstructionTypeID-Table 1.csv"))

list(

  import = list(file = "~/tmp/zillow.csv"),

  data = list(
    "Rename dep_var"               = list(renamer ~ NULL, c("logerror" = "dep_var"))
   ,"Match factors"                = list(zillow.match_factors_from_files ~ NULL, factorized_variables, factor_legends)
#  ,"Factorize single valued vars" = list(factorize_single_valued_vars, function(x) length(unique(x)) == 2)
   ,"Drop truly single vars"       = list(drop_single_value_variables)
   ,"Drop character features"      = list(drop_variables, function(x) is.character(x) || is.factor(x))
  ),

  model = list('gbm'
    , .id_var             = 'parcelid'
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

 # nround           = 6500
 # eta              = 0.01
 # subsample        = 0.7
 # colsample_bytree = 0.35
 # weight           = TRUE
 # objective        = "reg:linear"
 # metrics          = "rmse"


)

