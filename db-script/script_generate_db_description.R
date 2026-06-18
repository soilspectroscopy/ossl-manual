library(googlesheets4)
library(dplyr)
library(stringr)
library(readr)

# ============================================================================
# CONFIGURATION — run from ossl-manual root:
#   source("scripts/script_generate_db_description_preview.R")
# ============================================================================
OUTPUT_QMD <- "db-desc.qmd"
CSS_PATH   <- "styles/db-description.css"

# ============================================================================
# 1. Authorize and read sheets
# ============================================================================
# gs4_auth(email = "rzhi@woodwellclimate.org")
# gs4_auth(email = "jsafanelli@woodwellclimate.org")

coding_sheet_id <- "1KnPj2eUqrAZ_5JzEyXzZ-qvK8h6EcwQwRlR2-FXnbqg"

message("Reading Google Sheets...")
soillab  <- read_sheet(coding_sheet_id, sheet = "ossl_level0_names_soillab")
soilsite <- read_sheet(coding_sheet_id, sheet = "ossl_level0_names_soilsite")
mir      <- read_sheet(coding_sheet_id, sheet = "ossl_level0_names_mir")
visnir   <- read_sheet(coding_sheet_id, sheet = "ossl_level0_names_visnir")
nir      <- read_sheet(coding_sheet_id, sheet = "neospectra_names_nir")
message("Done reading sheets.")

# ============================================================================
# 2. Helpers
# ============================================================================
esc <- function(x) {
  x <- as.character(x)
  x[is.na(x) | trimws(x) == ""] <- ""
  x <- gsub("&",  "&amp;",  x, fixed = TRUE)
  x <- gsub("<",  "&lt;",   x, fixed = TRUE)
  x <- gsub(">",  "&gt;",   x, fixed = TRUE)
  x <- gsub("\"", "&quot;", x, fixed = TRUE)
  x
}

# Safe column getter — returns "" if column not present
col_val <- function(r, col_name) {
  if (col_name %in% names(r)) esc(r[[col_name]]) else ""
}

# ============================================================================
# 3. Category badge styles
# ============================================================================
cat_badge_style <- function(cat) {
  switch(tolower(trimws(cat)),
    "physical"           = "background:#E1F5EE;color:#0F6E56",
    "chemical"           = "background:#E6F1FB;color:#185FA5",
    "carbon & nutrients" = "background:#FAEEDA;color:#854F0B",
    "metal elements"     = "background:#FAECE7;color:#993C1D",
    "biological"         = "background:#FBEAF0;color:#993556",
    "hydrological"       = "background:#EAF3DE;color:#3B6D11",
    "background:#F1EFE8;color:#5F5E5A"
  )
}

# ============================================================================
# 4. Build HTML rows — adapts to whatever columns exist in each sheet
# ============================================================================
make_rows <- function(df) {
  has_unit      <- "ossl_unit"        %in% names(df)
  has_analyte   <- "analyte"          %in% names(df)
  has_abbrev    <- "ossl_abbrev"      %in% names(df)
  has_method    <- "ossl_method"      %in% names(df)
  has_unit_desc <- "unit_description" %in% names(df)
  has_type      <- "type"             %in% names(df)

  # total visible columns: expand btn + code + desc + optional unit + optional type
  n_cols <- 1 + 1 + 1 +
    (if (has_unit) 1 else 0) +
    (if (has_type) 1 else 0)

  rows <- character(nrow(df))
  for (i in seq_len(nrow(df))) {
    r        <- df[i, ]
    code     <- col_val(r, "ossl_name")
    desc     <- col_val(r, "description")
    type_val <- col_val(r, "type")
    example  <- col_val(r, "example")
    abbrev   <- col_val(r, "ossl_abbrev")
    method   <- col_val(r, "ossl_method")
    unit     <- col_val(r, "ossl_unit")
    unit_desc <- col_val(r, "unit_description")
    analyte  <- if (has_analyte) col_val(r, "analyte") else desc

    detail_items <- paste0(
      if (has_analyte)   paste0('<div><div class="d-label">Full description</div>',
                                '<div class="d-val">', desc, '</div></div>\n') else '',
      if (has_method)    paste0('<div><div class="d-label">OSSL method</div>',
                                '<div class="d-val">', method, '</div></div>\n') else '',
      if (has_unit_desc) paste0('<div><div class="d-label">Unit description</div>',
                                '<div class="d-val">', unit_desc, '</div></div>\n') else '',
      '<div><div class="d-label">Example value</div>',
          '<div class="d-val"><code>', example, '</code></div></div>\n',
      if (has_abbrev)    paste0('<div><div class="d-label">OSSL abbreviation</div>',
                                '<div class="d-val">', abbrev, '</div></div>\n') else ''
    )

    rows[i] <- paste0(
      '<tr data-code="', code, '" data-desc="', desc, '">\n',
      '  <td class="exp-cell"><button class="exp-btn" aria-label="expand row">+</button></td>\n',
      '  <td><code class="ossl-code">', code, '</code></td>\n',
      '  <td class="desc-col">', analyte, '</td>\n',
      if (has_unit) paste0('  <td class="unit-col">', unit, '</td>\n') else '',
      if (has_type) paste0('  <td class="type-col">', type_val, '</td>\n') else '',
      '</tr>\n',
      '<tr class="detail-row">\n',
      '  <td colspan="', n_cols, '">\n',
      '    <div class="detail-grid">\n', detail_items, '    </div>\n',
      '  </td>\n',
      '</tr>\n'
    )
  }
  paste(rows, collapse = "\n")
}

# ============================================================================
# 5. Category filter options
# ============================================================================
make_cat_options <- function(df) {
  if (!"category" %in% names(df)) return("")
  cats <- sort(unique(trimws(as.character(df$category))))
  cats <- cats[cats != "" & !is.na(cats)]
  opts <- paste0('<option value="', esc(cats), '">', esc(cats), '</option>', collapse = "\n")
  paste0('<option value="">All categories</option>\n', opts)
}

# ============================================================================
# 6. Build one tab panel
# ============================================================================
make_tab_panel <- function(df, panel_id, intro = "") {
  has_unit  <- "ossl_unit" %in% names(df)
  has_type  <- "type"      %in% names(df)
  n         <- nrow(df)
  rows_html <- make_rows(df)

  unit_th <- if (has_unit) '<th style="width:110px">OSSL UNIT</th>' else ""
  type_th <- if (has_type) '<th style="width:110px">DATA TYPE</th>' else ""

  intro_html <- if (nzchar(intro)) {
    paste0('  <div class="panel-intro">\n', intro, '\n  </div>\n')
  } else ""

  paste0(
    '<div id="', panel_id, '" class="tab-panel" style="display:none" role="tabpanel">\n',
    intro_html,
    '  <div class="search-row">\n',
    '    <input type="text" id="', panel_id, '-srch"\n',
    '           placeholder="Search by code or description&#x2026;" aria-label="Search variables">\n',
    '  </div>\n',
    '  <p class="count-note" id="', panel_id, '-cnt">Showing ', n, ' variables</p>\n',
    '  <div class="table-wrap">\n',
    '  <table id="', panel_id, '-tbl">\n',
    '    <thead><tr>\n',
    '      <th class="exp-cell"></th>\n',
    '      <th class="code-col">OSSL CODE</th>\n',
    '      <th>DESCRIPTION</th>\n',
    '      ', unit_th, '\n',
    '      ', type_th, '\n',
    '    </tr></thead>\n',
    '    <tbody>\n', rows_html, '    </tbody>\n',
    '  </table>\n',
    '  </div>\n',
    '</div>\n'
  )
}

# ============================================================================
# 7. Intro paragraphs for spectral tabs
# ============================================================================
intro_mir <- '
<p><strong>Middle-infrared (MIR) spectra</strong> is provided in absorbance units per
wavenumber, with values usually ranging between 0 and 3. The spectral range imported
into the OSSL falls between 600 and 4000 cm<sup>-1</sup>, with an interval of 2 cm<sup>-1</sup>.
All datasets are standardized to this specification.</p>

<p>One can convert reflectance (R) values to absorbance units (A) as
<code>A = log10(1/R)</code>, or backtransform with <code>R = 1/(10^A)</code>.
Similarly, headers containing wavenumbers (WN, in cm<sup>-1</sup>) can be converted
to wavelength (WL, in nm) with <code>WL = 1/(WN/10000000)</code>, or backtransformed
with <code>WN = 1/(WL/10000000)</code>. The factor 10M is used to convert cm to nm.</p>
'

intro_visnir <- '
<p><strong>Visible and Near-Infrared (VisNIR) spectra</strong> is provided in
reflectance units per wavelength, with values usually ranging between 0 and 1 as
fraction percent. The spectral range imported into the OSSL falls between 350 and
2500 nm, with an interval of 2 nm. All datasets are standardized to this specification.</p>

<p>One can convert reflectance (R) values to absorbance units (A) as
<code>A = log10(1/R)</code>, or backtransform with <code>R = 1/(10^A)</code>.
Similarly, headers containing wavenumbers (WN, in cm<sup>-1</sup>) can be converted
to wavelength (WL, in nm) with <code>WL = 1/(WN/10000000)</code>, or backtransformed
with <code>WN = 1/(WL/10000000)</code>. The factor 10M is used to convert cm to nm.</p>
'

intro_nir <- '
<p><strong>Near-Infrared (NIR) spectra</strong> from the Neospectra handheld
instrument is provided in reflectance units per wavelength, typically ranging between
0 and 1. The spectral range imported into the OSSL falls between 700 and 2550 nm,
with an interval of 2 nm.</p>

<p>Reflectance (R) values can be converted to absorbance units (A) using
<code>A = log10(1/R)</code>, or backtransformed with <code>R = 1/(10^A)</code>.
Wavelength (WL, in nm) and wavenumber (WN, in cm<sup>-1</sup>) are related by
<code>WL = 1/(WN/10000000)</code> and <code>WN = 1/(WL/10000000)</code>.</p>
'

# ============================================================================
# 8. Build panels
# ============================================================================
message("Building tab panels...")
panel_soillab  <- make_tab_panel(soillab,  "panel-soillab")
panel_soilsite <- make_tab_panel(soilsite, "panel-soilsite")
panel_mir      <- make_tab_panel(mir,      "panel-mir",    intro_mir)
panel_visnir   <- make_tab_panel(visnir,   "panel-visnir", intro_visnir)
panel_nir      <- make_tab_panel(nir,      "panel-nir",    intro_nir)
message("All panels built.")

n_soillab  <- nrow(soillab)
n_soilsite <- nrow(soilsite)
n_mir      <- nrow(mir)
n_visnir   <- nrow(visnir)
n_nir      <- nrow(nir)

# ============================================================================
# 9. Compose QMD
# ============================================================================
qmd_text <- paste0(
'---
title: "Database description"
format:
  html:
    toc: false
    css: ', CSS_PATH, '
    include-in-header:
      text: |
        <style>#title-block-header { display: none !important; }</style>
---

```{=html}
<h1 class="db-page-title">Database description</h1>
<p class="db-page-intro">
  Variable names, types, measurement units, analytical methods, and
  plain-language descriptions for all fields in the OSSL database.
  Use the tabs to browse each data type, the search box to find a specific
  variable, and click the <strong>+</strong> button on any row to expand its
  full details.
</p>

<div class="db-tabs" role="tablist">
  <button class="db-tab active" role="tab" aria-selected="true"
          aria-controls="panel-soillab" data-target="panel-soillab">
    Soil lab <span class="tab-count">', n_soillab, '</span>
  </button>
  <button class="db-tab" role="tab" aria-selected="false"
          aria-controls="panel-soilsite" data-target="panel-soilsite">
    Soil site <span class="tab-count">', n_soilsite, '</span>
  </button>
  <button class="db-tab" role="tab" aria-selected="false"
          aria-controls="panel-mir" data-target="panel-mir">
    MIR scans <span class="tab-count">', n_mir, '</span>
  </button>
  <button class="db-tab" role="tab" aria-selected="false"
          aria-controls="panel-visnir" data-target="panel-visnir">
    VisNIR scans <span class="tab-count">', n_visnir, '</span>
  </button>
  <button class="db-tab" role="tab" aria-selected="false"
          aria-controls="panel-nir" data-target="panel-nir">
    NIR scans <span class="tab-count">', n_nir, '</span>
  </button>
</div>

', panel_soillab, '
', panel_soilsite, '
', panel_mir, '
', panel_visnir, '
', panel_nir, '

<script>
(function () {
  document.querySelectorAll(".db-tab").forEach(function (btn) {
    btn.addEventListener("click", function () {
      document.querySelectorAll(".db-tab").forEach(function (b) {
        b.classList.remove("active"); b.setAttribute("aria-selected","false");
      });
      document.querySelectorAll(".tab-panel").forEach(function (p) {
        p.style.display = "none";
      });
      btn.classList.add("active"); btn.setAttribute("aria-selected","true");
      var t = document.getElementById(btn.dataset.target);
      if (t) t.style.display = "block";
    });
  });

  document.addEventListener("click", function (e) {
    if (!e.target.classList.contains("exp-btn")) return;
    var tr   = e.target.closest("tr");
    var next = tr.nextElementSibling;
    if (!next || !next.classList.contains("detail-row")) return;
    var open = next.style.display === "table-row";
    next.style.display = open ? "none" : "table-row";
    e.target.textContent = open ? "+" : "\u2212";
  });

  function setupFilter(panelId) {
    var panel = document.getElementById(panelId); if (!panel) return;
    var srch  = document.getElementById(panelId + "-srch");
    var catf  = document.getElementById(panelId + "-catf");
    var cnt   = document.getElementById(panelId + "-cnt");
    var rows  = panel.querySelectorAll("tbody tr:not(.detail-row)");
    var total = rows.length;
    function applyFilter() {
      var q = srch ? srch.value.toLowerCase() : "";
      var c = catf ? catf.value.toLowerCase() : "";
      var shown = 0;
      rows.forEach(function (tr) {
        var match = (!q || (tr.dataset.code||"").toLowerCase().includes(q) ||
                           (tr.dataset.desc||"").toLowerCase().includes(q)) &&
                    (!c  || (tr.dataset.cat||"").toLowerCase() === c);
        tr.style.display = match ? "" : "none";
        var next = tr.nextElementSibling;
        if (next && next.classList.contains("detail-row") && !match)
          next.style.display = "none";
        if (match) shown++;
      });
      if (cnt) cnt.textContent = "Showing " + shown + " of " + total + " variables";
    }
    if (srch) srch.addEventListener("input",  applyFilter);
    if (catf) catf.addEventListener("change", applyFilter);
  }
  ["panel-soillab","panel-soilsite","panel-mir","panel-visnir","panel-nir"].forEach(setupFilter);

  // Show the panel matching the URL hash, or the first one
  var hash = window.location.hash.replace("#", "");
  var validIds = ["panel-soillab","panel-soilsite","panel-mir","panel-visnir","panel-nir"];
  var targetId = validIds.indexOf(hash) >= 0 ? hash : "panel-soillab";

  document.querySelectorAll(".db-tab").forEach(function (b) {
    b.classList.remove("active");
    b.setAttribute("aria-selected", "false");
  });
  document.querySelectorAll(".tab-panel").forEach(function (p) {
    p.style.display = "none";
  });
  var targetPanel = document.getElementById(targetId);
  var targetTab = null;
  document.querySelectorAll(".db-tab").forEach(function (b) {
    if (b.getAttribute("data-target") === targetId) targetTab = b;
  });
  if (targetPanel) targetPanel.style.display = "block";
  if (targetTab) {
    targetTab.classList.add("active");
    targetTab.setAttribute("aria-selected", "true");
  }
})();
</script>
```
'
)

# ============================================================================
# 10. Write output
# ============================================================================
dir.create(dirname(OUTPUT_QMD), recursive = TRUE, showWarnings = FALSE)
writeLines(qmd_text, OUTPUT_QMD)
message("Written: ", OUTPUT_QMD)
