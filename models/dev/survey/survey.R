# Using Syberia to analyze a survey.  Namely, the 2008 ANES election survey.

# Unlike most Syberia files which are focused on creating a predictive model, here we
# will just use Syberia to clean the data and then analyze it in some different ways.

# Our goal here is to look at data from the 2008 ANES election survey, look at the
# time-series data and see whether people who feel they understand the issues were
# more favorable toward Obama at the time of the eleciton.

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
    # ANES uses crazy names, so let's rename some variables.
    "Rename" = list(renamer, list("V083004" = "voted2008",
                                  "V083037a" = "obama_tmp",
                                  "V083079b" = "understand_issues"))
    # We're only interested in looking at the people who actually voted, so we
    # can subset.
    ,"Subset to only those who voted" = list(
        list(select_rows, NULL),
        function(df) { df$voted2008 == "1. Yes" }, whole = TRUE)
    # The understand_issues variable in ANES is a mess, so we will recode into numbers.
    , "Clean issue understanding" = list(value_replacer, 'understand_issues',
        list("-1. INAP, R selected for VERSION D" = NA,
             "1. Agree strongly" = 5,
             "2. Agree somewhat" = 4,
             "3. Neither agree nor disagree" = 3,
             "4. Disagree somewhat" = 2,
             "5. Disagree strongly" = 1,
             "-8. Don't know" = 1))
    # THe data has to be numeric, so we use a column transformation.
    , "Turn to numeric" = list(column_transformation(as.numeric), 'understand_issues')
  ) 

  # While models have a model stage, survey analysis has an analyze stage.
  # The analyze stage prints the results of each computation for you to review.
  ,analyze = list(
    "Mean Obama favorability" =
        function(df) mean(df$obama_tmp, na.rm = TRUE)
    , "Mean self-reported issue understanding" =
        function(df) mean(df$understand_issues, na.rm = TRUE)
    , "Look at mean Obama favorability by issue understanding" =
        function(df) tapply(df$obama_tmp, df$understand_issues, mean)
    # Here we see:
    #       1        2        3        4        5
    #       61.94737 57.15517 59.00000 63.16010 67.01230
    # ...which means that as issue understanding goes toward 5 (greater understanding)
    # Obama favoriability increases.
    , "Feelings toward obama x understand issues chisq test" =
        function(df) chisq.test(df$obama_tmp, df$understand_issues)
    # We then look at a Chi Square test which shows the result is statistically significant.
  ))
