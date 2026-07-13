# Adapted from Dataverse scripts/recodes_s2.R — .tab paths only; relevel in prep_studies.R

wave1_s2 <- read_study_tab("study2") %>%
  filter(!duplicated(PROLIFIC_PID_anon) & Progress == 100) %>%
  filter(!grepl("conductor", elicited_attitude))

wave2_s2 <- read_study_tab("study2_wave2") %>%
  filter(!duplicated(PROLIFIC_PID_anon))

wave2_s2_r <- wave1_s2 %>%
  left_join(wave2_s2, by = "PROLIFIC_PID_anon", suffix = c("_w1", ""))

wave1_s2 <- wave1_s2 %>%
  mutate(
    attitude_defense_scale_pre = 8 -
      psych::alpha(select(., matches("attitude_defense_1")), check.keys = TRUE)$scores,
    attitude_defense_scale_w1 = 8 -
      psych::alpha(select(., matches("attitude_defense_2")), check.keys = TRUE)$scores,
    attitude_extremity_w1 =
      psych::alpha(select(., matches("attitude_extremity_[0-9]")), check.keys = TRUE)$scores
  )

wave2_s2_r <- wave2_s2_r %>%
  mutate(
    attrition = as.numeric(is.na(Progress)),
    certainty_w1 = certainty2_19,
    certainty_w2 = certainty3_19,
    attitude_defense_scale_w1 = 8 -
      psych::alpha(select(., matches("attitude_defense_1")), check.keys = TRUE)$scores,
    attitude_defense_scale_w1out = 8 -
      psych::alpha(select(., matches("attitude_defense_2")), check.keys = TRUE)$scores,
    attitude_defense_scale_w2 = 8 -
      psych::alpha(select(., matches("attitude_defense_3")), check.keys = TRUE)$scores,
    attitude_extremity_w1 =
      psych::alpha(select(., matches("attitude_extremity_[0-9]")), check.keys = TRUE)$scores,
    attitude_extremity_w2 =
      psych::alpha(select(., matches("attitude_extremity3_[0-9]")), check.keys = TRUE)$scores,
    additional_consideration = !is.na(relevance3_3_TEXT),
    additional_consideration_relevance = ifelse(is.na(relevance3_3), 1, relevance3_3),
    recall_true = (as.numeric(recall_closed_1 == 2) + as.numeric(recall_closed_2 == 2)) / 2,
    recall_fake1 = (as.numeric(recall_closed_3 == 2) + as.numeric(recall_closed_4 == 2)) / 2,
    recall_fake2 = (as.numeric(recall_closed_5 == 2) + as.numeric(recall_closed_6 == 2)) / 2,
    recall_focal = case_when(
      treatment == "core_belief" ~ recall_true,
      treatment == "distal_belief" ~ recall_fake1,
      treatment == "placebo" ~ recall_fake1
    ),
    recall_distal = case_when(
      treatment == "core_belief" ~ recall_fake1,
      treatment == "distal_belief" ~ recall_true,
      treatment == "placebo" ~ recall_fake2
    ),
    recall_placebo = case_when(
      treatment == "core_belief" ~ recall_fake2,
      treatment == "distal_belief" ~ recall_fake2,
      treatment == "placebo" ~ recall_true
    )
  )
