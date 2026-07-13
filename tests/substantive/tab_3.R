# Substantive checks for Table 3 — Velez, Liu & Clifford (APSR 2026)
#
# Benchmarks: APSR Table 3, belief relevance models (coef, SE, N, R²).

tab_3_relevance_benchmark <- function() {
  data.frame(
    model_id = c(
      "s1_focal", "s1_focal",
      "s1_distal", "s1_distal",
      "s2_focal", "s2_focal",
      "s2_distal", "s2_distal"
    ),
    term = rep(c("treatmentcore_belief", "treatmentdistal_belief"), 4L),
    coef = c(-0.17, -0.04, -0.12, -0.20, -0.09, 0.005, -0.06, -0.13),
    se = c(0.03, 0.02, 0.03, 0.03, 0.03, 0.03, 0.04, 0.04),
    nobs = c(2470L, 2470L, 2471L, 2471L, 1679L, 1679L, 1679L, 1679L),
    rsquared = c(0.202, 0.202, 0.367, 0.367, 0.160, 0.160, 0.227, 0.227),
    stringsAsFactors = FALSE
  )
}

resolve_tab_3_benchmarks <- function(object) {
  if (is.list(object) && !is.null(object$benchmarks) && is.data.frame(object$benchmarks)) {
    return(object$benchmarks)
  }
  if (is.list(object) && !is.null(object$object)) {
    inner <- object$object
    if (is.list(inner) && !is.null(inner$benchmarks)) {
      return(inner$benchmarks)
    }
  }
  if (is.list(object) && !is.null(object$models)) {
    source_path <- file.path(
      Sys.getenv("REPLICATE_STUDY_ROOT", unset = "."),
      "code", "tables", "tab_3.R"
    )
    if (file.exists(source_path)) {
      env <- new.env(parent = globalenv())
      source(source_path, local = env)
      if (exists("extract_lm_robust_benchmarks", envir = env, inherits = FALSE)) {
        return(get("extract_lm_robust_benchmarks", envir = env)(object$models))
      }
    }
  }
  roots <- unique(c(
    Sys.getenv("REPLICATE_STUDY_ROOT", unset = ""),
    getwd()
  ))
  roots <- roots[nzchar(roots)]
  for (root in roots) {
    candidate <- file.path(root, "outputs", "tab_3", "tab_3_benchmarks.csv")
    if (file.exists(candidate)) {
      return(utils::read.csv(candidate, stringsAsFactors = FALSE))
    }
  }
  stop("Could not resolve Table 3 benchmarks from replication result.", call. = FALSE)
}

check_tab_3_benchmark <- function(actual, spec, tolerance = 0.015) {
  failures <- character(0)
  for (i in seq_len(nrow(spec))) {
    row <- actual[
      actual$model_id == spec$model_id[[i]] & actual$term == spec$term[[i]],
      ,
      drop = FALSE
    ]
    label <- paste0(spec$model_id[[i]], " / ", spec$term[[i]])
    if (nrow(row) != 1L) {
      failures <- c(failures, paste0(label, ": not found in replicated output"))
      next
    }
    if (abs(row$coef - spec$coef[[i]]) > tolerance) {
      failures <- c(
        failures,
        sprintf("%s coef: expected %.3f, got %.3f", label, spec$coef[[i]], row$coef)
      )
    }
    if (abs(row$se - spec$se[[i]]) > tolerance) {
      failures <- c(
        failures,
        sprintf("%s se: expected %.3f, got %.3f", label, spec$se[[i]], row$se)
      )
    }
    if (as.integer(row$nobs) != spec$nobs[[i]]) {
      failures <- c(
        failures,
        sprintf("%s N: expected %d, got %d", label, spec$nobs[[i]], as.integer(row$nobs))
      )
    }
    if (abs(row$rsquared - spec$rsquared[[i]]) > tolerance) {
      failures <- c(
        failures,
        sprintf("%s R2: expected %.3f, got %.3f", label, spec$rsquared[[i]], row$rsquared)
      )
    }
  }
  if (length(failures) > 0L) {
    stop(
      "Published benchmark check failed:\n",
      paste0(" - ", failures, collapse = "\n"),
      call. = FALSE
    )
  }
  invisible(TRUE)
}

#' @param object Replication result or velez_tab_3 object from `make_tab_3()`.
#' @param tolerance Numeric tolerance for coef/se/R² (default 0.015 for 2 d.p. table).
substantive_check_tab_3 <- function(object, tolerance = 0.015) {
  actual <- resolve_tab_3_benchmarks(object)
  check_tab_3_benchmark(actual, tab_3_relevance_benchmark(), tolerance = tolerance)
}
