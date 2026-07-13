# Build analysis frames from Dataverse .tab files via committed deposit adapters.
# Author logic: code/deposit/recodes_s*.R (from Dataverse scripts/, .tab paths only).

source("../helpers/dataverse_deposit.R")

make_prep_studies <- function() {
  load_velez_packages()
  deposit <- deposit_root()
  if (!dir.exists(file.path(deposit, "data"))) {
    stop("Run access_deposit first (missing ", deposit, "/data).", call. = FALSE)
  }
  Sys.setenv(VELEZ_DEPOSIT_DIR = deposit)

  env <- new.env(parent = globalenv())
  deposit_code <- file.path(study_root(), "code", "deposit")
  source(file.path(deposit_code, "read_study_tab.R"), local = env)
  source(file.path(deposit_code, "recodes_s1.R"), local = env)
  source(file.path(deposit_code, "recodes_s2.R"), local = env)
  relevel_study_treatments(env)

  out_path <- studies_output_path()
  dir.create(dirname(out_path), recursive = TRUE, showWarnings = FALSE)
  saveRDS(as.list(env), out_path)
  out_path
}
