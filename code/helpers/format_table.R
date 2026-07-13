format_tab_1 <- function(object) {
  if (!is.data.frame(object)) {
    stop("format_tab_1 expects a data.frame.", call. = FALSE)
  }
  knitr::kable(object, format = "html", caption = "Table 1: Summary Statistics for Variables Across Studies") |>
    kableExtra::kable_styling(bootstrap_options = c("striped", "hover"), full_width = FALSE)
}

format_tab_1_stata <- format_tab_1

format_tab_3 <- function(object) {
  if (!is.list(object) || is.null(object$models)) {
    stop("format_tab_3 expects a velez_tab_3 object with $models.", call. = FALSE)
  }
  models <- object$models
  additional_rows <- tibble::tibble(
    term = "Covariates Included",
    `S1: Focal relevance` = "$\\checkmark$",
    `S1: Distal relevance` = "$\\checkmark$",
    `S2: Focal relevance` = "$\\checkmark$",
    `S2: Distal relevance` = "$\\checkmark$"
  )
  modelsummary::modelsummary(
    list(
      "S1: Focal relevance" = models$s1_focal,
      "S1: Distal relevance" = models$s1_distal,
      "S2: Focal relevance" = models$s2_focal,
      "S2: Distal relevance" = models$s2_distal
    ),
    coef_map = c(
      "treatmentcore_belief" = "Focal counterargument",
      "treatmentdistal_belief" = "Distal counterargument"
    ),
    gof_map = c("nobs", "r.squared"),
    title = "Table 3: Effects of Interventions on Belief Relevance",
    fmt = 2,
    stars = TRUE,
    escape = FALSE,
    add_rows = additional_rows,
    output = "html"
  )
}

format_tab_3_stata <- format_tab_3
