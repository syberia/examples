if (!nzchar(Sys.getenv("R_ROOT"))) {
  Sys.setenv("R_ROOT" = "TRUE") # Don't re-lockbox for process forks, like GBM

  # Set important common options
  options(stringsAsFactors = FALSE)
  library(methods); library(utils); library(stats);
  options(menu.graphics = FALSE) # Disable tcl/tk for installation from CRAN
  options(repos = structure(c(CRAN = "http://streaming.stat.iastate.edu/CRAN/")))

  # Install all the packages that can't be managed by lockbox or Ramd.
  # Make sure we install it in the correct library, for users with multiple libPaths...
  main_lib <- if (Sys.getenv("R_LIBS_USER") %in% .libPaths()) {
    normalizePath(Sys.getenv("R_LIBS_USER"))
  } else {
    .libPaths()[[1]]
  }
  is_installed <- function(package) {
    package %in% utils::installed.packages(main_lib)[,1]
  }
  install_if_not_installed <- function(package) {
    if (!is_installed(package)) {
      install.packages(package, main_lib)
    }
  }
  # These are dependencies of dependencies that lockbox cannot manage yet.
  #TODO: Topological sort of the dependency graph!
  packages <- c("digest", "git2r", "Rcpp", "plyr", "arules", "lubridate", "rversions",
    "scales", "data.table", "ggplot2", "htmlwidgets", "vcd", "DiagrammeR", "stringr",
    "iterators", "foreach", "R6", "curl", "rjson", "httr", "crayon", "timeDate")
  invisible(lapply(packages, install_if_not_installed))

  if (!is_installed("devtools") ||
    utils::packageVersion("devtools") < package_version("1.10.0.9000")) {
    # To get modern devtools, we will first have to install devtools at v0.9.1
    # because of the nefarious withr dependency that breaks on R 3.1.
    #TODO: Use regular devtools once the withr change happens on CRAN.
    # Then we will install withr and then install the correct devtools.
    message("Upgrading your devtools circuitously... Thanks Jim Hester...")
    packageurl <- "http://cran.r-project.org/src/contrib/Archive/devtools/devtools_1.9.1.tar.gz"
    install.packages(packageurl, repos = NULL, type = "source")
    if (!is_installed("withr")) {
      # Install the dev version of withr that doesn't have an R 3.2 dependency.
      # Damn you, Jim Hester!
      #TODO: Fix this when Jim Hester comes to his senses.
      devtools::install_github("jimhester/withr@00d1e7ac68fbfd13720580a3ae1615a4df3f7aad")
    }
    # Now unload everything in the correct order.
    unloadNamespace("httr")
    unloadNamespace("R6")
    unloadNamespace("devtools")
    # Now install the correct devtools.
    devtools::install_github("hadley/devtools")
  }
  if (!is_installed("Ramd") ||
    utils::packageVersion("Ramd") < package_version("0.3.8")) {
      # We like Ramd to load packages in bulk, once its dependencies are ready.
      devtools::install_github("robertzk/Ramd")
  }

  # Use bettertrace for better stacktraces.
  Ramd::packages("robertzk/bettertrace")
  # lockbox can't do magrittr or testthatesomemore
  Ramd::packages("magrittr", "robertzk/testthatsomemore@0.2.4")

  # Now we install lockbox.
  if (!is_installed("lockbox") ||
    utils::packageVersion("lockbox") < package_version("0.1.2")) {
      if (file.exists("~/.R/lockbox") || file.exists("~/.R/lockbox.experimental")) {
        message("\033[31mWiping lockbox directory...\033[39m\n") # Manual crayon in manualbox!
        old_version <- tryCatch(utils::packageVersion("lockbox"), error = function(e) { "old" })
        system(paste0("mv ~/.R/lockbox ~/.R/lockbox-", old_version))
      }
      for (path in .libPaths()) {
        try(utils::remove.packages("lockbox", lib = path), silent = TRUE)
      }
      devtools::install_github("robertzk/lockbox")
  }


  # Update Roxygen
  #TODO: Can this go into lockbox?
  if (utils::packageVersion("roxygen2") != package_version("4.1.1")) {
    Ramd::packages("crayon")
    packageStartupMessage(crayon::green("Updating roxygen...\n"))
    devtools::install_github("klutometis/roxygen", ref = "v4.1.1")
  }

  # Run lockbox
  options(lockbox.env = if (!nzchar(Sys.getenv("CI"))) "development" else "test")
  # Oddly solves lockbox problem https://github.com/avantcredit/avant-analytics/issues/1186
  if (!"R6" %in% loadedNamespaces()) { library(R6) }
  lockbox::lockbox("lockfile.yml")

  # Run user-specific Rprofile
  # Calling syberia_project within ~/.Rprofile causes infinite loops, so we disable it temporarily.
  assign("syberia_project", local({ calls <- list(); function(...) { calls <<- list(calls, list(...)) } }), envir = globalenv())
  invisible(local({
    syberia_project_calls <- environment(get("syberia_project", envir = globalenv()))$calls
    rm("syberia_project", envir = globalenv())
    lapply(syberia_project_calls, function(call) { do.call(syberia_project, call) })
  }))
  config_files <- c("~/.Rprofile")
  invisible(lapply(config_files, function(x) { if (file.exists(x)) source(x) }))
}
