

# Scripts & workflow for `Datasets` update

This directory contains the automation and generator scripts for the
OSSL Manual website.

## 1. Directory Structure

- `scripts/`: Generator and automation scripts.
- `tabular/`: Reference lookup tables, color palettes, and URL mappings.
- `datasets/`: Quarto content for individual dataset pages (`*.qmd`),
  subsite config (`_quarto.yml`), card listing feed (`cards.yml`), and
  logos (`logo/`).

## 2. R Scripts — Order of Execution

Always run scripts from the **repository root** as the working
directory.

| \# | Script | What it does | When to run |
|----|----|----|----|
| 1 | `scripts/01_generate_logo.R` | Generates hexagon logos (one PNG per dataset) into `datasets/logo/` and saves palette to `tabular/logo_color_palette.csv`. | Only when adding new datasets. |
| 2 | `scripts/02_generate_map_url.R` | Reads the `Access` tab and updates the `map_url` column back in the Google Sheet. | After adding new datasets, or if map URLs need refreshing. |
| 3 | `scripts/03_generate_cards.R` | Reads `Access` tab + `tabular/logo_color_palette.csv`. Writes `datasets/cards.yml` (feeds `libraries.qmd`) and caches `tabular/OSSL_v2_listed_libraries.csv`. | After any change to listing-page data (description, sample size, spectral range, extent, logo color). |
| 4 | `scripts/04_generate_dataset_qmd.R` | Reads `Access`, `Soil_site`, `Soil_lab`, `MIR`, `VNIR`, `NIR` tabs + `tabular/ossl_individual_datasets_urls_v1.3.csv` + `tabular/logo_color_palette.csv` + GitHub READMEs. Generates one `.qmd` per dataset in `datasets/`. | After any change to dataset detail pages. |
| \- | `scripts/generate_db_description.R` | Reads property coding sheets and compiles the database description page `db-desc.qmd`. | When database property codes or descriptions change. |
| \- | `scripts/build_all_datasets.R` | Convenience runner that sources `03_generate_cards.R` then `04_generate_dataset_qmd.R`. | Standard dataset update workflow. |

## 3. Typical Update Workflow

### Updating Existing Datasets (after editing Google Sheet)

``` r
# In R (from project root):
source("scripts/build_all_datasets.R")
```

Then compile in the terminal:

``` bash
quarto render
quarto render datasets/
quarto preview
```

### Adding New Datasets

``` r
# In R (from project root):
source("scripts/01_generate_logo.R")      # creates new logo PNGs + updates palette
source("scripts/02_generate_map_url.R")   # optional: auto-populates map_url in sheet
source("scripts/build_all_datasets.R")    # generates cards.yml and dataset .qmd files
```

Then compile in the terminal:

``` bash
quarto render
quarto render datasets/
quarto preview
```

## 4. Sources

The Google Sheet is the source of truth:  
- **Sheet ID:** `19PuiJx1mzNaFff4odODNzS6ZB72lcz9UbcVPWCt8Gz8`.  
- **Tabs:** `Access`, `Soil_site`, `Soil_lab`, `MIR`, `VNIR`, `NIR`.  
- **Property Coding Sheet ID:**
`1KnPj2eUqrAZ_5JzEyXzZ-qvK8h6EcwQwRlR2-FXnbqg`.
