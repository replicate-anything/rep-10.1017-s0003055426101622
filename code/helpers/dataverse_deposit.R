# Dataverse deposit helpers — rep-10.1017-s0003055426101622

`%||%` <- function(a, b) if (is.null(a)) b else a

study_root <- function() {
  root <- Sys.getenv("REPLICATE_STUDY_ROOT", unset = "")
  if (!nzchar(root)) "." else root
}

read_dataverse_config <- function() {
  cfg <- yaml::read_yaml(file.path(study_root(), "replication.yml"))$dataverse
  if (is.null(cfg)) {
    stop("replication.yml must define a dataverse: block.", call. = FALSE)
  }
  cfg
}

deposit_root <- function() {
  cfg <- read_dataverse_config()
  file.path(study_root(), cfg$deposit_root %||% "outputs/deposit")
}

download_manifest_file <- function(row, deposit_dir, server = "dataverse.harvard.edu") {
  replicateEverything:::download_dataverse_manifest_file(
    row,
    deposit_dir,
    server = server
  )
}

access_deposit_archive <- function(deposit_dir = deposit_root(), cfg = read_dataverse_config()) {
  replicateEverything:::access_dataverse_deposit_archive(
    dataset = cfg$dataset,
    deposit_root = deposit_dir,
    server = cfg$server %||% "dataverse.harvard.edu",
    original = TRUE
  )
}

inspect_dataverse_formats <- function(dataset = NULL, server = "dataverse.harvard.edu") {
  cfg <- read_dataverse_config()
  dataset <- dataset %||% cfg$dataset
  if (is.null(dataset) || !nzchar(dataset)) {
    stop("dataverse.dataset is required.", call. = FALSE)
  }
  meta <- dataverse::get_dataset(dataset, server = server)
  files <- meta$files
  tabular <- files[
    files$contentType == "text/tab-separated-values" |
      files$tabularData %in% TRUE |
      grepl("\\.(tab|csv|dta|rds)$", files$filename, ignore.case = TRUE),
    ,
    drop = FALSE
  ]
  data.frame(
    filename = tabular$filename,
    original = tabular$originalFileName %||% NA_character_,
    format = tabular$originalFormatLabel %||% NA_character_,
    local_path = ifelse(
      nzchar(tabular$originalFileName),
      file.path(dirname(tabular$filename), tabular$originalFileName),
      tabular$filename
    ),
    stringsAsFactors = FALSE
  )
}

read_dataverse_manifest <- function(phase = "mvp") {
  cfg <- read_dataverse_config()
  manifest_path <- file.path(study_root(), cfg$manifest %||% "manifest/dataverse_files.csv")
  if (!file.exists(manifest_path)) {
    stop("Dataverse manifest not found: ", manifest_path, call. = FALSE)
  }
  manifest <- utils::read.csv(manifest_path, stringsAsFactors = FALSE)
  if (!is.null(phase) && "phase" %in% names(manifest)) {
    manifest <- manifest[manifest$phase == phase, , drop = FALSE]
  }
  manifest
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

relevel_study_treatments <- function(env) {
  safe_relevel <- function(x, ref = "placebo") {
    f <- factor(x, levels = c("placebo", "core_belief", "distal_belief"))
    if (ref %in% levels(f)) relevel(f, ref) else f
  }
  if (exists("wave1_s1", envir = env, inherits = FALSE)) {
    env$wave1_s1$treatment <- safe_relevel(env$wave1_s1$treatment)
  }
  if (exists("wave2_s1", envir = env, inherits = FALSE)) {
    env$wave2_s1$treatment <- safe_relevel(env$wave2_s1$treatment)
  }
  if (exists("wave2_s2_r", envir = env, inherits = FALSE)) {
    env$wave2_s2_r$treatment <- safe_relevel(env$wave2_s2_r$treatment)
  }
  invisible(env)
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
