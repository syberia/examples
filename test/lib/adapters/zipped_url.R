testthat::with_mock(
  `utils::download.file` = function(...) { NULL },
  `utils::unzip` = function(...) { iris },
  `readr::read_csv` = function(...) { ..1 }, {
    test_that("it can read a data set from a zipped URL", {
      adapter <- resource()
      expect_identical(adapter$read("test_key"), iris)
    })

    test_that("it cannot write", {
      adapter <- resource()
      expect_error(adapter$write(iris, "test_key"))
    })
})
