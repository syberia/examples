TRAIN_CUTOFF <- 463715

list(
  import = list(
    zipped_url = 'https://archive.ics.uci.edu/ml/machine-learning-databases/00203/YearPredictionMSD.txt.zip'
  ),

  data = list(
     "Rename dep_var"                = list( renamer ~ NULL, c(X1  = 'dep_var'))
    ,"Rename timbre average vars"    = list( renamer, setNames(paste0('timbre_average_', 1:12), paste0('X', 2:13)))
    ,"Rename timbre covariance vars" = list( renamer, setNames(paste0('timbre_cov_', 1:78), paste0('X', 14:91)))
    ,"Select training rows"          = list( select_rows ~ NULL, 1:TRAIN_CUTOFF)
    ,"Drop sparse years"             = list( select_rows ~ NULL, function(df) { bad_factors <- as.numeric(names(which(table(as.factor(df$dep_var)) < 5))); !df$dep_var %in% bad_factors}, whole = TRUE)
    ,"Set year as factor"            = list( column_transformation(function(x) as.factor(as.character(x))), c('dep_var'))
  ),

  model = list('gbm'
    , distribution        = 'multinomial'
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

  export = list(
    s3 = 'syberia/uci/msd/gbm',
    R  = 'MSD'
  )
)
