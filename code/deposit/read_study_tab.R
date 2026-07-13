# Read a .tab file from the Dataverse deposit cache (author scripts expect .csv paths).
read_study_tab <- function(name) {
  deposit <- Sys.getenv("VELEZ_DEPOSIT_DIR", unset = "")
  if (!nzchar(deposit)) {
    stop("VELEZ_DEPOSIT_DIR must be set to outputs/deposit before sourcing recodes.", call. = FALSE)
  }
  path <- file.path(deposit, "data", paste0(name, ".tab"))
  if (!file.exists(path)) {
    stop("Missing deposit data file: ", path, call. = FALSE)
  }
  utils::read.delim(
    path,
    header = TRUE,
    quote = "",
    comment.char = "",
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
}
