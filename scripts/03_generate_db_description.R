## Builds db-desc.qmd from the OSSL property coding sheet.
## Run from repository root when property codes or descriptions change.

library(googlesheets4)

gs4_auth(email = "jsafanelli@woodwellclimate.org")
coding_sheet_id <- "1KnPj2eUqrAZ_5JzEyXzZ-qvK8h6EcwQwRlR2-FXnbqg"

# ---------- Intros ----------
conversion <- '
<p>One can convert reflectance (R) values to absorbance units (A) as
<code>A = log10(1/R)</code>, or backtransform with <code>R = 1/(10^A)</code>.
Similarly, headers containing wavenumbers (WN, in cm<sup>-1</sup>) can be converted
to wavelength (WL, in nm) with <code>WL = 1/(WN/10000000)</code>, or backtransformed
with <code>WN = 1/(WL/10000000)</code>. The factor 10M is used to convert cm to nm.</p>
'

intro_mir <- paste0('
<p><strong>Middle-infrared (MIR) spectra</strong> are provided in absorbance units per
wavenumber, with values usually ranging between 0 and 3. The spectral range imported
into the OSSL falls between 600 and 4000 cm<sup>-1</sup>, with an interval of 2 cm<sup>-1</sup>.
All datasets are standardized to this specification.</p>
', conversion)

intro_visnir <- paste0('
<p><strong>Visible and Near-Infrared (VisNIR) spectra</strong> are provided in
reflectance units per wavelength, with values usually ranging between 0 and 1 as
fraction percent. The spectral range imported into the OSSL falls between 350 and
2500 nm, with an interval of 2 nm. All datasets are standardized to this specification.</p>
', conversion)

intro_nir <- paste0('
<p><strong>Near-Infrared (NIR) spectra</strong> from the Neospectra handheld
instrument are provided in reflectance units per wavelength, typically ranging between
0 and 1. The spectral range imported into the OSSL falls between 700 and 2550 nm,
with an interval of 2 nm.</p>
', conversion)

# ---------- Tabs ----------
tabs <- data.frame(
  id    = c("soillab", "soilsite", "mir", "visnir", "nir"),
  label = c("Soil lab", "Soil site", "MIR scans", "VisNIR scans", "NIR scans"),
  sheet = c("ossl_level0_names_soillab", "ossl_level0_names_soilsite",
            "ossl_level0_names_mir", "ossl_level0_names_visnir", "neospectra_names_nir"),
  intro = c("", "", intro_mir, intro_visnir, intro_nir)
)
tabs$panel <- paste0("panel-", tabs$id)

# ---------- Helpers ----------
esc <- function(x) {
  x <- as.character(x)
  x[is.na(x)] <- ""
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  gsub("\"", "&quot;", x, fixed = TRUE)
}

# Column as escaped vector, or "" if the sheet does not have it
col <- function(df, name) if (name %in% names(df)) esc(df[[name]]) else rep("", nrow(df))

detail <- function(label, val) {
  paste0('<div><div class="d-label">', label, '</div><div class="d-val">', val, '</div></div>\n')
}

make_rows <- function(df) {
  has <- function(name) name %in% names(df)
  code <- col(df, "ossl_name")
  desc <- col(df, "description")
  short <- if (has("analyte")) col(df, "analyte") else desc
  n_cols <- 3 + has("ossl_unit") + has("type")

  details <- paste0(
    if (has("analyte")) detail("Full description", desc) else "",
    if (has("ossl_method")) detail("OSSL method", col(df, "ossl_method")) else "",
    if (has("unit_description")) detail("Unit description", col(df, "unit_description")) else "",
    detail("Example value", paste0("<code>", col(df, "example"), "</code>")),
    if (has("ossl_abbrev")) detail("OSSL abbreviation", col(df, "ossl_abbrev")) else ""
  )

  paste0(
    '<tr data-code="', code, '" data-desc="', desc, '">\n',
    '  <td class="exp-cell"><button class="exp-btn" aria-label="expand row">+</button></td>\n',
    '  <td><code class="ossl-code">', code, '</code></td>\n',
    '  <td class="desc-col">', short, '</td>\n',
    if (has("ossl_unit")) paste0('  <td class="unit-col">', col(df, "ossl_unit"), '</td>\n') else "",
    if (has("type")) paste0('  <td class="type-col">', col(df, "type"), '</td>\n') else "",
    '</tr>\n',
    '<tr class="detail-row"><td colspan="', n_cols, '">\n',
    '  <div class="detail-grid">\n', details, '  </div>\n',
    '</td></tr>\n',
    collapse = "\n"
  )
}

make_panel <- function(df, panel, intro) {
  paste0(
    '<div id="', panel, '" class="tab-panel" style="display:none" role="tabpanel">\n',
    if (nzchar(intro)) paste0('<div class="panel-intro">\n', intro, '\n</div>\n') else "",
    '<div class="search-row">\n',
    '  <input type="text" id="', panel, '-srch" placeholder="Search by code or description&#x2026;" aria-label="Search variables">\n',
    '</div>\n',
    '<p class="count-note" id="', panel, '-cnt">Showing ', nrow(df), ' variables</p>\n',
    '<div class="table-wrap">\n<table id="', panel, '-tbl">\n',
    '<thead><tr><th class="exp-cell"></th><th class="code-col">OSSL CODE</th><th>DESCRIPTION</th>',
    if ("ossl_unit" %in% names(df)) '<th style="width:110px">OSSL UNIT</th>' else "",
    if ("type" %in% names(df)) '<th style="width:110px">DATA TYPE</th>' else "",
    '</tr></thead>\n<tbody>\n', make_rows(df), '</tbody>\n</table>\n</div>\n</div>\n'
  )
}

# ---------- Build ----------
sheets <- lapply(tabs$sheet, function(s) read_sheet(coding_sheet_id, sheet = s))

buttons <- paste0(
  '<button class="db-tab" role="tab" aria-selected="false" aria-controls="', tabs$panel,
  '" data-target="', tabs$panel, '">', tabs$label,
  ' <span class="tab-count">', vapply(sheets, nrow, integer(1)), '</span></button>',
  collapse = "\n"
)

panels <- paste(mapply(make_panel, sheets, tabs$panel, tabs$intro), collapse = "\n")

js_ids <- paste0('"', tabs$panel, '"', collapse = ",")

qmd <- paste0(
'---
title: "Database description"
format:
  html:
    toc: false
    css: styles/db-description.css
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
', buttons, '
</div>

', panels, '

<script>
(function () {
  var ids = [', js_ids, '];

  function show(id) {
    document.querySelectorAll(".db-tab").forEach(function (b) {
      var on = b.dataset.target === id;
      b.classList.toggle("active", on);
      b.setAttribute("aria-selected", on);
    });
    ids.forEach(function (p) {
      document.getElementById(p).style.display = p === id ? "block" : "none";
    });
  }

  document.querySelectorAll(".db-tab").forEach(function (b) {
    b.addEventListener("click", function () { show(b.dataset.target); });
  });

  document.addEventListener("click", function (e) {
    if (!e.target.classList.contains("exp-btn")) return;
    var next = e.target.closest("tr").nextElementSibling;
    if (!next || !next.classList.contains("detail-row")) return;
    var open = next.style.display === "table-row";
    next.style.display = open ? "none" : "table-row";
    e.target.textContent = open ? "+" : "\\u2212";
  });

  ids.forEach(function (id) {
    var srch = document.getElementById(id + "-srch");
    var cnt  = document.getElementById(id + "-cnt");
    var rows = document.querySelectorAll("#" + id + " tbody tr:not(.detail-row)");
    srch.addEventListener("input", function () {
      var q = srch.value.toLowerCase(), shown = 0;
      rows.forEach(function (tr) {
        var match = !q || tr.dataset.code.toLowerCase().includes(q) ||
                          tr.dataset.desc.toLowerCase().includes(q);
        tr.style.display = match ? "" : "none";
        if (!match) tr.nextElementSibling.style.display = "none";
        if (match) shown++;
      });
      cnt.textContent = "Showing " + shown + " of " + rows.length + " variables";
    });
  });

  var hash = window.location.hash.replace("#", "");
  show(ids.indexOf(hash) >= 0 ? hash : ids[0]);
})();
</script>
```
')

writeLines(qmd, "db-desc.qmd")
message("Wrote db-desc.qmd")
