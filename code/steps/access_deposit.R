# Fetch Harvard Dataverse deposit — full original-format archive, unzip, verify, prune.
# Paper: 10.1017/S0003055426101622 | Dataverse: 10.7910/DVN/BZOCDJ

source("../helpers/dataverse_deposit.R")

make_access_deposit <- function(phase = "mvp") {
  cfg <- read_dataverse_config()
  server <- cfg$server %||% "dataverse.harvard.edu"
  dataset <- cfg$dataset
  if (is.null(dataset) || !nzchar(dataset)) {
    stop("dataverse.dataset is required in replication.yml.", call. = FALSE)
  }
  deposit_dir <- deposit_root()
  dir.create(deposit_dir, recursive = TRUE, showWarnings = FALSE)

  replicateEverything:::access_dataverse_deposit_archive(
    dataset = dataset,
    deposit_root = deposit_dir,
    server = server,
    original = TRUE
  )

  manifest <- read_dataverse_manifest(phase = phase)
  expected <- manifest$path
  replicateEverything:::verify_deposit_paths(expected, deposit_dir)
  replicateEverything:::prune_deposit_paths(expected, deposit_dir)

  marker <- file.path(deposit_dir, ".manifest_applied")
  writeLines(
    c(
      paste0("phase=", phase),
      paste0("downloaded_at=", format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")),
      paste0("n_expected=", length(expected)),
      "fetch=archive_original"
    ),
    marker
  )

  list(deposit_dir = deposit_dir, files = expected, marker = marker)
}
