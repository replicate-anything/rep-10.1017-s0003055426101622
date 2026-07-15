# Table 3 — effects of interventions on belief relevance
# Study: https://github.com/replicate-anything/rep-10.1017-s0003055426101622
#
# Upstream prep (not re-run here): prep_studies → outputs/prep_studies/studies.rds
# Live Run / Display assume that prep product already exists (or is built via the DAG).

source("../helpers/study_inputs.R")

TAB_3_COEF_LABELS <- c(
  "treatmentcore_belief" = "Focal counterargument",
  "treatmentdistal_belief" = "Distal counterargument"
)

TAB_3_TREATMENT_TERMS <- c("treatmentcore_belief", "treatmentdistal_belief")

extract_lm_robust_benchmarks <- function(models) {
  rows <- lapply(names(models), function(model_id) {
    model <- models[[model_id]]
    nobs <- stats::nobs(model)
    rsquared <- unname(summary(model)$r.squared)
    lapply(TAB_3_TREATMENT_TERMS, function(term) {
      data.frame(
        model_id = model_id,
        term = term,
        coef = unname(stats::coef(model)[term]),
        se = unname(model$std.error[term]),
        nobs = nobs,
        rsquared = rsquared,
        stringsAsFactors = FALSE
      )
    })
  })
  do.call(rbind, unlist(rows, recursive = FALSE))
}

write_tab_3_benchmarks <- function(benchmarks) {
  out_dir <- file.path(study_root(), "outputs", "tab_3")
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  out_path <- file.path(out_dir, "tab_3_benchmarks.csv")
  utils::write.csv(benchmarks, out_path, row.names = FALSE)
  out_path
}

fit_tab_3_models <- function(wave1_s1, wave2_s2_r) {
  list(
    s1_focal = estimatr::lm_robust(
      relevance_1 ~ treatment + attitude_strength + belief_strength_str + belief_strength_wk,
      wave1_s1
    ),
    s1_distal = estimatr::lm_robust(
      relevance_2 ~ treatment + attitude_strength + belief_strength_str + belief_strength_wk,
      wave1_s1
    ),
    s2_focal = estimatr::lm_robust(
      relevance3_1 ~ treatment + attitude_strength_w1 + belief_strength_str_w1 +
        belief_strength_wk_w1 + attitude_defense_scale_w1,
      wave2_s2_r
    ),
    s2_distal = estimatr::lm_robust(
      relevance3_2 ~ treatment + attitude_strength_w1 + belief_strength_str_w1 +
        belief_strength_wk_w1 + attitude_defense_scale_w1,
      wave2_s2_r
    )
  )
}

make_tab_3 <- function(data) {
  load_velez_packages()
  if (is.null(data)) {
    data <- load_studies_objects()
  }
  models <- fit_tab_3_models(data$wave1_s1, data$wave2_s2_r)
  benchmarks <- extract_lm_robust_benchmarks(models)
  write_tab_3_benchmarks(benchmarks)
  structure(
    list(models = models, benchmarks = benchmarks),
    class = "velez_tab_3"
  )
}

# Executable replication path: load prep output → make_tab_3() → format_tab_3()
if (!exists("format_tab_3", mode = "function")) {
  source("../helpers/format_table.R")
}
make_tab_3(readRDS("../outputs/prep_studies/studies.rds")) |> format_tab_3()
