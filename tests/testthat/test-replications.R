test_that("replication.yml structure", {
  yml <- yaml::read_yaml("replication.yml")
  expect_equal(yml$paper$doi, "https://doi.org/10.1017/S0003055426101622")
  expect_equal(yml$dataverse$doi, "https://doi.org/10.7910/DVN/BZOCDJ")
  expect_true("access_deposit" %in% vapply(yml$steps, `[[`, "", "id"))
  expect_true("tab_1" %in% vapply(yml$steps, `[[`, "", "id"))
})

test_that("dataverse manifest lists expected deposit paths", {
  manifest <- utils::read.csv("manifest/dataverse_files.csv", stringsAsFactors = FALSE)
  expect_true(any(manifest$path == "data/study1.csv"))
  expect_true(any(manifest$path == "scripts/recodes_s1.R"))
})

test_that("list_replications includes tab_1", {
  options(
    replicateEverything.study_folders_root = normalizePath("..", winslash = "/"),
    replicateEverything.registry_root = normalizePath("../registry", winslash = "/"),
    replicateEverything.use_sibling_packages = TRUE
  )
  devtools::load_all("../replicateEverything")
  reps <- list_replications("10.1017/S0003055426101622")
  expect_true("tab_1" %in% reps$id)
})
