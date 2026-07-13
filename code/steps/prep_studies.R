# Source unedited author recodes from outputs/deposit/ (expects data/*.csv layout).

source("../helpers/dataverse_deposit.R")

make_prep_studies <- function() {
  load_velez_packages()
  deposit <- deposit_root()
  if (!dir.exists(file.path(deposit, "data"))) {
    stop("Run access_deposit first (missing ", deposit, "/data).", call. = FALSE)
  }
  for (req in c(
    "data/study1.csv",
    "data/study2.csv",
    "scripts/recodes_s1.R",
    "scripts/recodes_s2.R"
  )) {
    if (!file.exists(file.path(deposit, req))) {
      stop("Missing deposit file: ", req, " (re-run access_deposit).", call. = FALSE)
    }
  }

  env <- new.env(parent = globalenv())
  env$relevel <- function(x, ref, ...) {
    if (!is.factor(x)) {
      x <- as.factor(x)
    }
    if (!missing(ref) && ref %in% levels(x)) {
      stats::relevel(x, ref = ref, ...)
    } else {
      x
    }
  }
  owd <- getwd()
  on.exit(setwd(owd), add = TRUE)
  setwd(deposit)

  source("scripts/recodes_s1.R", local = env)
  source("scripts/recodes_s2.R", local = env)
  relevel_study_treatments(env)

  out_path <- studies_output_path()
  dir.create(dirname(out_path), recursive = TRUE, showWarnings = FALSE)
  saveRDS(as.list(env), out_path)
  out_path
}
