if (!nzchar(Sys.getenv("R_ROOT"))) {
  library(methods)
  library(utils)
  library(stats)

  Sys.setenv("R_ROOT" = "TRUE") # Don't re-lockbox for process forks, like GBM.

  options(lockbox.verbose = TRUE, # Set to TRUE to get verbose lockbox output.
          # Set important common options.
          stringsAsFactors = FALSE,
          menu.graphics = FALSE, # Disable tcl/tk for installation from CRAN.
          repos = structure(c(CRAN = "http://streaming.stat.iastate.edu/CRAN/")))

  # Install all the packages that can't be managed by lockbox or Ramd.
  # Make sure we install it in the correct library for users with multiple libPaths...
  if (Sys.getenv("R_LIBS_USER") %in% .libPaths()) {
    main_lib <- normalizePath(Sys.getenv("R_LIBS_USER"))
  } else {
    main_lib <- .libPaths()[[1]]
  }

  is_installed <- function(package) {
    package %in% utils::installed.packages(main_lib)[, 1]
  }

  install_if_not_installed <- function(package) {
    if (!is_installed(package)) {
      install.packages(package, main_lib, type = "source",
                       quiet = !isTRUE(getOption("lockbox.verbose")))
    }
  }

  download <- function(path, url, ...) {
    request <- httr::GET(url, ...)
    httr::stop_for_status(request)
    writeBin(httr::content(request, "raw"), path)
    path
  }

  # Because lockbox is installed manually, we install its dependencies manually.
  lapply(c("httr", "yaml", "digest", "crayon"), install_if_not_installed)

  # Now we install lockbox.
  if (!is_installed("lockbox") || packageVersion("lockbox") < package_version("0.2.4")) {
    for (path in .libPaths()) {
      try(utils::remove.packages("lockbox", lib = path), silent = TRUE)
    }
    lockbox_tar <- tempfile(fileext = ".tar.gz")
    lockbox_url <- "https://github.com/robertzk/lockbox/archive/0.2.4.tar.gz"
    download(lockbox_tar, lockbox_url)
    install.packages(lockbox_tar, repos = NULL, type = "source")
    unlink(lockbox_tar, TRUE, TRUE)
  }

  lockbox::lockbox("lockfile.yml")
  library(bettertrace)  # Make it easier to find errors.
  syberia::syberia_engine()

  # Run user-specific Rprofile
  config_files <- c("~/.Rprofile")
  lapply(config_files, function(x) { if (file.exists(x)) source(x) })
  invisible(NULL)
}

