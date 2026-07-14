# Table 1 — summary statistics (logic from Replication.Rmd chunk; data via deposit recodes)

source("../helpers/dataverse_deposit.R")

make_tab_1 <- function(data) {
  load_velez_packages()
  if (is.null(data)) {
    data <- load_studies_objects()
  }
  list2env(data, envir = environment())

  bind_rows(
    wave1_s1 %>%
      mutate(
        `Attitude Strength` = attitude_strength,
        `Belief Strength (Focal)` = belief_strength_str,
        `Belief Strength (Distal)` = belief_strength_wk,
        `Belief Relevance (Focal)` = relevance_1,
        `Belief Relevance (Distal)` = relevance_2
      ) %>%
      dplyr::reframe(
        across(
          c(
            `Attitude Strength`, `Belief Strength (Focal)`,
            `Belief Strength (Distal)`, `Belief Relevance (Focal)`,
            `Belief Relevance (Distal)`
          ),
          list(
            Mean = ~ mean(.x, na.rm = TRUE),
            SD = ~ sd(.x, na.rm = TRUE),
            SE = ~ sd(.x, na.rm = TRUE) / sqrt(length(.x)),
            Percent_Max = ~ mean(.x == max(.x, na.rm = TRUE), na.rm = TRUE) * 100
          ),
          .names = "{col}_{fn}"
        )
      ) %>%
      pivot_longer(
        cols = everything(),
        names_to = c("Variable", "Statistic"),
        names_pattern = "^(.*)_(Mean|SD|SE|Percent_Max)$"
      ) %>%
      group_by(Variable) %>%
      dplyr::summarise(
        Study1 = sprintf(
          "%.2f (%.2f); %.1f%% selected max",
          value[Statistic == "Mean"],
          value[Statistic == "SE"],
          value[Statistic == "Percent_Max"]
        ),
        .groups = "drop"
      ),
    wave2_s2_r %>%
      filter(treatment == "placebo") %>%
      mutate(
        `Attitude Strength` = attitude_strength_w1,
        `Belief Strength (Focal)` = belief_strength_str_w1,
        `Belief Strength (Distal)` = belief_strength_wk_w1,
        `Belief Relevance (Focal)` = relevance_1,
        `Belief Relevance (Distal)` = relevance_2
      ) %>%
      dplyr::reframe(
        across(
          c(
            `Attitude Strength`, `Belief Strength (Focal)`,
            `Belief Strength (Distal)`, `Belief Relevance (Focal)`,
            `Belief Relevance (Distal)`
          ),
          list(
            Mean = ~ mean(.x, na.rm = TRUE),
            SD = ~ sd(.x, na.rm = TRUE),
            SE = ~ sd(.x, na.rm = TRUE) / sqrt(length(.x)),
            Percent_Max = ~ mean(.x == max(.x, na.rm = TRUE), na.rm = TRUE) * 100
          ),
          .names = "{col}_{fn}"
        )
      ) %>%
      pivot_longer(
        cols = everything(),
        names_to = c("Variable", "Statistic"),
        names_pattern = "^(.*)_(Mean|SD|SE|Percent_Max)$"
      ) %>%
      group_by(Variable) %>%
      dplyr::summarise(
        Study2 = sprintf(
          "%.2f (%.2f); %.1f%% selected max",
          value[Statistic == "Mean"],
          value[Statistic == "SE"],
          value[Statistic == "Percent_Max"]
        ),
        .groups = "drop"
      )
  ) %>%
    group_by(Variable) %>%
    dplyr::summarise(
      `Study 1` = dplyr::first(Study1),
      `Study 2` = dplyr::last(Study2),
      .groups = "drop"
    ) %>%
    as.data.frame()
}
