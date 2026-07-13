# Data source

Materials are fetched at run time from Harvard Dataverse as a **full original-format archive**, then unzipped into `outputs/deposit/`.

| Field | Value |
|-------|--------|
| Paper DOI | [10.1017/S0003055426101622](https://doi.org/10.1017/S0003055426101622) |
| Dataverse DOI | [10.7910/DVN/BZOCDJ](https://doi.org/10.7910/DVN/BZOCDJ) |
| Fetch | `format=original` dataset zip |
| Manifest | `manifest/dataverse_files.csv` (expected paths after unzip) |
| Local cache | `outputs/deposit/` (gitignored) |

API:

```r
GET(
  "https://dataverse.harvard.edu/api/access/dataset/:persistentId/?persistentId=doi:10.7910/DVN/BZOCDJ&format=original",
  write_disk("dataset.zip", overwrite = TRUE)
)
```

After unzip the layout matches the author delivery: `data/study1.csv`, `scripts/recodes_s1.R`, `ReadMe.txt`, etc.

Local mirror for onboarding: `original_studies/10.1017-S0003055426101622/`.
