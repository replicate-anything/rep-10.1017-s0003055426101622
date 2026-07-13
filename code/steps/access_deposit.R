# Fetch Harvard Dataverse deposit files into outputs/deposit/
# Paper: 10.1017/S0003055426101622 | Dataverse: 10.7910/DVN/BZOCDJ

source("../helpers/dataverse_deposit.R")

make_access_deposit <- function(phase = "mvp") {
  cfg <- read_dataverse_config()
  server <- cfg$server %||% "dataverse.harvard.edu"
  deposit_dir <- deposit_root()
  dir.create(deposit_dir, recursive = TRUE, showWarnings = FALSE)

  manifest <- read_dataverse_manifest(phase = phase)
  downloaded <- character(0)
  for (i in seq_len(nrow(manifest))) {
    rel_path <- manifest$path[[i]]
    file_id <- manifest$id[[i]]
    dest <- file.path(deposit_dir, rel_path)
    download_dataverse_file(file_id, dest, server = server)
    downloaded <- c(downloaded, rel_path)
  }

  marker <- file.path(deposit_dir, ".manifest_applied")
  writeLines(
    c(
      paste0("phase=", phase),
      paste0("downloaded_at=", format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")),
      paste0("n_files=", length(downloaded))
    ),
    marker
  )

  list(deposit_dir = deposit_dir, files = downloaded, marker = marker)
}
