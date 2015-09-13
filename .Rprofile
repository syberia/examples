library(methods); library(utils); library(stats);
options(menu.graphics = FALSE) # Disable tcl/tk for installation from CRAN
options(repos=structure(c(CRAN="http://streaming.stat.iastate.edu/CRAN/")))
if (!"bettertrace" %in% utils::installed.packages()[,1]) devtools::install_github('robertzk/bettertrace')
library(bettertrace);
if (!require(Ramd)) devtools::install_github("robertzk/Ramd")
Ramd::packages("magrittr")
if (!nzchar(Sys.getenv("CI")) && (!is.element("lockbox", installed.packages()[, 1]) || utils::packageVersion("lockbox") != package_version("0.1.10"))) {
  devtools::install_github("robertzk/lockbox")
}

if (packageVersion("roxygen2") != package_version("4.1.1")) {
  # fixing roxygen version to make pull-requests cleaner
  Ramd::packages("crayon")
  packageStartupMessage(crayon::green("Updating roxygen...\n"))
  devtools::install_github("klutometis/roxygen", ref = "v4.1.1")
}

options(lockbox.env = if (!nzchar(Sys.getenv("CI"))) "development" else "test")

if (!nzchar(Sys.getenv("R_ROOT"))) suppressPackageStartupMessages(library(lockbox))
Sys.setenv("R_ROOT" = "TRUE") # Don't re-lockbox for process forks, like GBM

# Calling syberia_project within ~/.Rprofile causes infinite loops, so we disable it temporarily.
assign("syberia_project", local({ calls <- list(); function(...) { calls <<- list(calls, list(...)) } }), envir = globalenv())
if (file.exists("~/.Rprofile")) source("~/.Rprofile")
invisible(local({
  syberia_project_calls <- environment(get("syberia_project", envir = globalenv()))$calls
  rm("syberia_project", envir = globalenv())
  lapply(syberia_project_calls, function(call) { do.call(syberia_project, call) })
}))
