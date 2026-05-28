# OSSL Manual — Working Notes

---

## 1. What changed (quick summary)

- **Listing page (`libraries.qmd`)** — custom EJS template replaces Quarto's default grid; each card has a tinted band, spectral pills, extent line, stats, and a "View dataset" CTA. Whole card is clickable.
- **Dataset detail pages** — restructured: hero banner + quick-stats strip → map → database access (with download table) → soil lab table (auto-pulled from `ossl-imports` READMEs) → soil site bullets → MIR/VNIR/NIR → references.
- **Visual identity** — banner tints derived from each logo's color, kept consistent via `datasets/logo_color_palette.csv`.

---

## 2. R scripts — order of execution

Four scripts in `datasets/`. Run them from R with the project as the working directory.

| # | Script | What it does | When to run |
|---|--------|-------------|-------------|
| 1 | `script_generate_logo.R` | Generates hexagon logos (one PNG per dataset) into `datasets/logo/`. | Only when adding new datasets. |
| 2 | `script_generate_map_url.R` | Reads the `Access` tab and writes the `map_url` column back to the Google Sheet, constructed from each dataset's `old_code` plus the standard `ossl-imports` README map path. Saves manually entering URLs row by row. | After adding a new set datasets, or if map URLs need refreshing. |
| 3 | `script_generate_cards.R` | Reads the `Access` tab + `logo_color_palette.csv`. Writes `datasets/cards.yml`, which feeds the listing page via the EJS template. | After any change to listing-page data (description, sample size, spectral range, extent, logo color). |
| 4 | `script_generate_dataset_qmd.R` | Reads `Access`, `Soil_site`, `MIR`, `VNIR`, `NIR` tabs + the URLs CSV + the logo palette + each dataset's GitHub README. Writes one `.qmd` per dataset. | After any change to detail-page data. |

Then `quarto render`, `quarto render datasets/`, `quarto preview` compiles and preview the changes.

**Typical full-rebuild order:**

```r
source("datasets/script_generate_logo.R")         # only if adding new datasets
source("datasets/script_generate_map_url.R")      # optional. Either by running this or manually update map_url in google spreadsheet
source("datasets/script_generate_cards.R")
source("datasets/script_generate_dataset_qmd.R")
```

then in the terminal:

```bash
quarto render
quarto render datasets/
quarto preview
```

---

## 3. Editing the Google Sheet → updating the site

The Google Sheet is the source of truth for almost everything. Workflow:

1. **Open the sheet** and edit the relevant tab.
2. **Regenerate locally** by sourcing whichever scripts apply (see table above). Both card and detail scripts re-read the sheet live each time.

---

## 4. Wishlist — what I'll work on next

1. **Framing paragraph above the soil-lab table on each detail page**, using the counts from the `Soil_lab` tab (`n_properties_available`, `n_properties_standardized`, `properties_themes`). Goal: make clear that the displayed properties are the OSSL-standardized subset, not the full original library.
2. **Tooltips on the OSSL property codes** so new users can hover for a plain-language description of each (e.g. `ph.h2o_usda.a268_index` → "pH from soil-water suspension, method usda.a268").
3. **Update the existing "Data description" page** to incorporate the OSSL property code information — definitions, units, methods — as a glossary-style reference.

---

*Last sync: May 22, 2026. Update this doc when something material changes.*
