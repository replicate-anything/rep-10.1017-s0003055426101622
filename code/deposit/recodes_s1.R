# Adapted from Dataverse scripts/recodes_s1.R — .tab paths only; relevel in prep_studies.R

wave1_s1 <- read_study_tab("study1") %>%
  filter(!duplicated(participantId_anon) & Progress == 100)

wave2_s1 <- read_study_tab("study1_wave2") %>%
  filter(!duplicated(participantId_anon)) %>%
  mutate(treatment_w1 = if_else(treatment_w1 == "", NA, treatment_w1))

attitude_fix <- read_study_tab("study1_wave2_fix") %>%
  select(participantId_anon, matches("attitude"))

wave2_s1 <- wave2_s1 %>%
  rows_update(attitude_fix, by = "participantId_anon")

wave2_s1 <- wave1_s1 %>%
  left_join(wave2_s1, by = "participantId_anon", suffix = c("", "_w2"))

wave1_s1 <- wave1_s1 %>%
  mutate(
    attitude_score = psych::alpha(select(., matches("attitude_extremity_[0-9]")),
                                check.keys = TRUE)$scores
  )

wave2_s1 <- wave2_s1 %>%
  mutate(
    attitude_score_w1 = psych::alpha(select(., matches("attitude_extremity_[0-9]")),
                                     check.keys = TRUE)$scores,
    attitude_score_w2 = psych::alpha(select(., contains("attitude_extremity3")),
                                     check.keys = TRUE)$scores,
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
  ) %>%
  filter(!is.na(treatment))
