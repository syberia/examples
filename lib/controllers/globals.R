preprocessor <- function(source_args, source) {
  if (base::exists('..director_inject', envir = parent.env(source_args$local), inherits = FALSE))
    parent.env(source_args$local)$director <- director
  else source_args$local$director <- director
  source()
}

function() input
