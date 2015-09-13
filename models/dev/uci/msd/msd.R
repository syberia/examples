list(
  import = list(
    zipped_url = 'https://archive.ics.uci.edu/ml/machine-learning-databases/00203/YearPredictionMSD.txt.zip'
  ),

  data = list(
  ),

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

  export = list(
    s3 = 'syberia/uci/msd/gbm',
    R  = 'MSD'
  )
)
