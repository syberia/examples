test_that("title factor creates a title factor", {
  df <- data.frame(
    id = seq(7),
    label = factor(c("mr", "mrs", "ms", "master", "rev", "dr", "other")),
    is_mister = c(TRUE, rep(FALSE, 6)),
    is_missus = c(FALSE, TRUE, rep(FALSE, 5)),
    is_miss   = c(rep(FALSE, 2), TRUE, rep(FALSE, 4)),
    is_master = c(rep(FALSE, 3), TRUE, rep(FALSE, 3)),
    is_rev    = c(rep(FALSE, 4), TRUE, rep(FALSE, 2)),
    is_dr     = c(rep(FALSE, 5), TRUE, FALSE))
  mb <- resource()
  munged_df <- mb$run(df)
  expect_equal(df$label, munged_df$title)
})
