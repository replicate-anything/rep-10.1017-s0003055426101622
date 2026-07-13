# Velez, Liu & Clifford (APSR 2026) — Beyond Belief Change

Folder-backed replication study for [replicateEverything](https://github.com/replicate-anything/replicateEverything).

| | |
|---|---|
| **Paper DOI** | [10.1017/S0003055426101622](https://doi.org/10.1017/S0003055426101622) |
| **Dataverse DOI** | [10.7910/DVN/BZOCDJ](https://doi.org/10.7910/DVN/BZOCDJ) |
| **Engine** | R (author `Replication.Rmd` on Dataverse) |

## Lightweight layout

This repo avoids copying author code when scripts can run unchanged from a Dataverse cache:

1. **`access_deposit`** — downloads files in `manifest/dataverse_files.csv` to `outputs/deposit/`
2. **`prep_studies`** — runs committed adapters in `code/deposit/` that read `.tab` files directly
3. **Tables** — thin `code/tables/tab_N.R` wrappers (Rmd chunks without separate author files)

Dataverse ships `study*.tab` only (metadata: original upload was CSV). Adapters read `.tab` in place — no tab→csv conversion step.

## Run

```r
options(
  replicateEverything.study_folders_root = "<monorepo>",
  replicateEverything.registry_root = "<monorepo>/registry"
)
run_replication(
  "10.1017/S0003055426101622",
  "tab_1",
  given = "nothing",
  format = TRUE,
  install_deps = TRUE
)
```

Fresh clone: use `given = "nothing"` so `access_deposit` runs before tables.

## Scope

MVP: **Table 1** only. Main-text Tables 3–5 and Figures 3–7 follow the same pattern (extend manifest + add `tab_N.R` / `fig_N.R` wrappers).

Author driver on Dataverse: `outputs/deposit/Replication.Rmd` (downloaded, not committed).
