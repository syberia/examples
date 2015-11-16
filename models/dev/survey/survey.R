# Using Syberia to analyze a survey.  Namely, the 2008 ANES election survey.

# Unlike most Syberia files which are focused on creating a predictive model, here we
# will just use Syberia to clean the data and then analyze it in some different ways.

# Our goal here is to look at data from the 2008 ANES election survey, look at the
# time-series data and see whether people became more favorable to Obama after he won
# the election.

list(
  # Here we use the file adapter to simply load a CSV from the same directory as the model.
  # Files are loaded relative to the root of the directory.
  import = list(
    file = "models/dev/survey/anes2008pre.csv"
  )

  # This data stage will be used to clean the data.
  # Data from surveys are usually very messy.
  # The left-hand side names the data cleaning step (called a "mungebit") and the
  # right-hand side defines it.
  ,data = list(
    # We have a lot of data that is 0 and 1 representing booleans, so we want to
    # transform this into the native R logical.
    "Convert 0 and 1 to boolean" = list(
        column_transformation(as.logical),
        function(x) { identical(sort(setdiff(unique(x), NA)), c(0L, 1L)) })
    # We're only interested in looking at the people who actually voted, so we
    # can subset.
    ,"Subset to only those who voted" = list(
        list(select_rows, NULL),
        function(df) { df$voted2008 == TRUE }, whole = TRUE)
    # We then can engineer a new variable looking at favorability.
    ,"Find the post-pre difference in Obama favorability" = list(
        new_variable,
        function(obama_tmp_pre, obama_tmp_post) { obama_tmp_post - obama_tmp_pre },
        "obama_tmp_diff"
    )
  ) 

  # While models have a model stage, survey analysis has an analyze stage.
  # The analyze stage prints the results of each computation for you to review.
  ,analyze = list(
    "Mean difference in Obama favorability" =
        function(df) mean(df$obama_tmp_diff, na.rm = TRUE),
    "Pre-election post-election t-test" =
        function(df) t.test(df$obama_tmp_pre, df$obama_tmp_post)
  )

  # After the analyze stage, we see that there is a mean difference of +7.984 in Obama
  # favorability (on an 100-point scale).  A t-test of favorability before and after the
  # election has p < 0.0001, which indicates statistical significance.
  #
  # Therefore we declare that there was an increase in average favorability toward Obama
  # after he got elected.
)
