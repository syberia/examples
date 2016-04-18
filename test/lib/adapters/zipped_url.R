test_that("it can read a data set from a zipped URL", {
  env <- list2env(list(test_key = iris))
  package_stub("utils", "download.file", function(...) { env[[..1]] }, {
    adapter <- resource()
    expect_identical(adapter$read("test_key"), env$test_key,
      info = "iris should have been read from the test_key in env")
  })
})

test_that("it cannot write", {
  env <- new.env()
  package_stub("utils", "download.file", function(...) { env[[..2]] <- ..1 }, {
    adapter <- resource()
    expect_error(adapter$write(iris, "test_key"))
  })
})

