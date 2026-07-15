# Shared inputs for table/figure scripts.
# Prep (prep_studies) must already have written outputs/prep_studies/studies.rds.
# Do not pull Dataverse / deposit helpers here — those belong in upstream prep steps.

`%||%` <- function(a, b) if (is.null(a)) b else a

study_root <- function() {
  root <- Sys.getenv("REPLICATE_STUDY_ROOT", unset = "")
  if (nzchar(root)) {
    return(root)
  }
  "."
}

load_velez_packages <- function() {
  packages <- c(
    "magrittr", "tidyverse", "dplyr", "tidyr", "stringr",
    "estimatr", "modelsummary", "broom", "forcats", "psych"
  )
  for (pkg in packages) {
    suppressWarnings(suppressPackageStartupMessages(
      library(pkg, character.only = TRUE)
    ))
  }
  invisible(NULL)
}

studies_output_path <- function() {
  file.path(study_root(), "outputs", "prep_studies", "studies.rds")
}

load_studies_objects <- function() {
  path <- studies_output_path()
  if (!file.exists(path)) {
    stop("Run prep_studies first (missing ", path, ").", call. = FALSE)
  }
  readRDS(path)
}
