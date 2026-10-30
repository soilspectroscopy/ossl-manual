

# Scripts & workflow for `Datasets` update

Generator scripts for the OSSL Manual dataset catalog.

## 1. Directory structure

- `scripts/`: generator scripts.
- `tabular/`: lookup tables, logo color palette, and dataset file URLs.
- `datasets/`: dataset pages (`*.qmd`), subsite config (`_quarto.yml`),
  card listing feed (`cards.yml`), and logos (`logo/`).

## 2. Scripts

Always run from the **repository root**.

| Script | What it does | When to run |
|----|----|----|
| `scripts/01_generate_logo.R` | Adds a color to `tabular/logo_color_palette.csv` and a hexagon logo to `datasets/logo/` for each new dataset code. Existing colors and logos are kept. | When adding new datasets. |
| `scripts/02_build_catalog.R` | Reads the Google Sheet tabs, `tabular/` tables, and ossl-imports READMEs/soilsite files. Writes `datasets/cards.yml` (feeds `libraries.qmd`) and one `.qmd` per dataset in `datasets/`. | After any change to the Google Sheet. |
| `scripts/03_generate_db_description.R` | Compiles `db-desc.qmd` from the property coding sheet. | When property codes or descriptions change. |

## 3. Workflow

``` r
source("scripts/01_generate_logo.R")   # only if new datasets were added
source("scripts/02_build_catalog.R")
source("scripts/03_generate_db_description.R")   # when property codes or descriptions change
```

Then in the terminal (always run the two renders in sequence):

``` bash
quarto render
quarto render datasets/
quarto preview
```

## 4. Sources

The Google Sheet is the source of truth:

- **Sheet ID:** `19PuiJx1mzNaFff4odODNzS6ZB72lcz9UbcVPWCt8Gz8`
- **Tabs:** `Access`, `Soil_site`, `Soil_lab`, `MIR`, `VNIR`, `NIR`
- **Property coding sheet ID:**
  `1KnPj2eUqrAZ_5JzEyXzZ-qvK8h6EcwQwRlR2-FXnbqg`

Map URLs are built from `old_code` in the `Access` tab, so the `map_url`
column in the sheet is no longer used.
