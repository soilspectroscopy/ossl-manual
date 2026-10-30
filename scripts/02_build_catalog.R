## Builds the dataset catalog: datasets/cards.yml and one datasets/<code>.qmd per dataset.
## Run from repository root after updating the Access sheet, then `quarto render`.

library("googlesheets4")
library("dplyr")
library("purrr")
library("stringr")
library("readr")
library("yaml")
library("httr")
library("colorspace")
library("arrow")

# ---------- Inputs ----------
gs4_auth(email = "jsafanelli@woodwellclimate.org")
sheet_id <- "19PuiJx1mzNaFff4odODNzS6ZB72lcz9UbcVPWCt8Gz8"

access    <- read_sheet(sheet_id, sheet = "Access")
soil_site <- read_sheet(sheet_id, sheet = "Soil_site")
soil_lab  <- read_sheet(sheet_id, sheet = "Soil_lab")
mir       <- read_sheet(sheet_id, sheet = "MIR")
vnir      <- read_sheet(sheet_id, sheet = "VNIR")
nir       <- read_sheet(sheet_id, sheet = "NIR")

ossl_codes <- read_sheet("1KnPj2eUqrAZ_5JzEyXzZ-qvK8h6EcwQwRlR2-FXnbqg",
                         sheet = "ossl_level0_names_soillab")

dataset_files <- read_csv("tabular/ossl_individual_datasets_urls_v1.3.csv", show_col_types = FALSE)

logo_palette  <- read_csv("tabular/logo_color_palette.csv", show_col_types = FALSE) |>
  select(new_code, hex_color)

GITHUB_BASE <- "https://raw.githubusercontent.com/soilspectroscopy/ossl-imports/main/dataset"

# ---------- Helpers ----------
fix_blank <- function(x, default = "") {
  x <- as.character(x)
  x[is.na(x) | trimws(x) == ""] <- default
  x
}

safe_value <- function(x, default = "Not available") {
  if (length(x) == 0 || all(is.na(x)) || all(trimws(as.character(x)) == "")) return(default)
  as.character(x[[1]])
}

# Word boundary so "nir" does not match inside "vnir"
has_range <- function(spec, range) {
  grepl(paste0("\\b", range, "\\b"), tolower(fix_blank(spec)))
}

html_escape <- function(x) {
  if (is.null(x) || length(x) == 0 || is.na(x) || x == "NULL") return("")
  x <- as.character(x)
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  x <- gsub("\"", "&quot;", x, fixed = TRUE)
  gsub("'", "&#39;", x, fixed = TRUE)
}

section_heading <- function(icon, title) {
  paste0('## <i class="bi bi-', icon, ' ossl-section-icon" aria-hidden="true"></i> ', title)
}

# ---------- Soil site (populated columns from the soilsite parquet) ----------
is_populated <- function(col) {
  if (is.numeric(col) || is.logical(col)) return(any(!is.na(col)))
  any(!is.na(col) & nzchar(trimws(as.character(col))))
}

fetch_soilsite_columns <- function(code) {
  url <- dataset_files$public_url[dataset_files$dataset_code == code &
                                  dataset_files$ossl_file == "ossl_soilsite_v1.3.parquet"]
  if (length(url) == 0) return(NULL)

  tmp <- tempfile(fileext = ".parquet")
  on.exit(unlink(tmp))
  df <- tryCatch({
    download.file(url[1], tmp, mode = "wb", quiet = TRUE)
    read_parquet(tmp)
  }, error = function(e) {
    message("Soilsite skipped for ", code, ": ", conditionMessage(e))
    NULL
  })
  if (is.null(df) || nrow(df) == 0) return(NULL)

  key <- "dataset.code_ascii_txt"
  list(n_total   = ncol(df) - 1,
       populated = setdiff(names(df)[vapply(df, is_populated, logical(1))], key))
}

make_bullets <- function(df_row, exclude = c("new_code", "old_code")) {
  if (nrow(df_row) == 0) return("Not available.\n")
  cols <- setdiff(names(df_row), exclude)
  vals <- vapply(cols, function(col) {
    v <- as.character(df_row[[col]][1])
    if (is.na(v) || trimws(v) == "") return(NA_character_)
    label <- gsub("_", " ", col)
    paste0("- **", toupper(substr(label, 1, 1)), substr(label, 2, nchar(label)), ":** ", v)
  }, character(1))
  vals <- vals[!is.na(vals)]
  if (length(vals) == 0) "Not available.\n" else paste(vals, collapse = "\n")
}

# ---------- Soil lab (skimr table from ossl-imports README) ----------
code_lookup <- setNames(
  lapply(seq_len(nrow(ossl_codes)), function(i) list(
    analyte = as.character(ossl_codes$analyte[[i]]),
    method  = as.character(ossl_codes$ossl_method[[i]]),
    unit    = as.character(ossl_codes$ossl_unit[[i]])
  )),
  trimws(as.character(ossl_codes$ossl_name))
)

tooltip_span <- function(code, info) {
  part <- function(cls, label, val) {
    val <- html_escape(val)
    if (nchar(val) == 0) return("")
    if (is.null(label)) paste0('<span class="', cls, '">', val, '</span>')
    else paste0('<span class="', cls, '">', label, ': <code>', val, '</code></span>')
  }
  paste0('<span class="ossl-tt">', html_escape(code), '<span class="ossl-tt-pop">',
         part("tt-analyte", NULL, info$analyte),
         part("tt-desc", "Method", info$method),
         part("tt-unit", "Unit", info$unit),
         '</span></span>')
}

parse_pipe_row <- function(line) {
  line <- sub("^\\|", "", sub("\\|$", "", trimws(line)))
  trimws(strsplit(line, "|", fixed = TRUE)[[1]])
}

pipe_table_to_html <- function(table_md) {
  if (is.na(table_md)) return(NA_character_)
  lines <- strsplit(table_md, "\n", fixed = TRUE)[[1]]
  lines <- lines[grepl("^\\s*\\|", lines)]
  if (length(lines) < 3) return(NA_character_)

  header <- parse_pipe_row(lines[1])
  align  <- vapply(parse_pipe_row(lines[2]), function(s) {
    l <- startsWith(s, ":"); r <- endsWith(s, ":")
    if (l && r) "center" else if (r) "right" else "left"
  }, character(1), USE.NAMES = FALSE)

  td <- function(tag, a, v) paste0("<", tag, " style=\"text-align:", a, "\">", v, "</", tag, ">")

  rows <- vapply(lines[-(1:2)], function(line) {
    cells <- parse_pipe_row(line)
    cells <- c(cells, rep("", max(0, length(header) - length(cells))))
    info  <- code_lookup[[cells[1]]]
    first <- if (!is.null(info)) tooltip_span(cells[1], info) else html_escape(cells[1])
    paste0("<tr>", td("td", align[1], first),
           paste(td("td", align[-1], vapply(cells[-1], html_escape, character(1))), collapse = ""),
           "</tr>")
  }, character(1), USE.NAMES = FALSE)

  paste0('<table class="soil-lab-table"><thead><tr>',
         paste(td("th", align, vapply(header, html_escape, character(1))), collapse = ""),
         "</tr></thead><tbody>", paste(rows, collapse = ""), "</tbody></table>")
}

fetch_soil_lab_summary <- function(code) {
  for (folder in unique(c(code, sub("[0-9]+$", "", code)))) {
    resp <- tryCatch(GET(paste0(GITHUB_BASE, "/", folder, "/README.md"), timeout(20)),
                     error = function(e) NULL)
    if (is.null(resp) || status_code(resp) != 200) next

    lines <- strsplit(gsub("\r\n?", "\n", content(resp, as = "text", encoding = "UTF-8")),
                      "\n", fixed = TRUE)[[1]]
    text  <- paste(lines, collapse = "\n")

    n_rows <- str_match(text, "Number of rows[^0-9]*([0-9]+)")[, 2]

    cleaned <- trimws(gsub("^[*#\\s]+|[*#\\s]+$", "", lines, perl = TRUE))
    marker  <- grep("^Variable type:\\s*numeric\\s*:?$", cleaned, ignore.case = TRUE)[1]
    if (is.na(marker)) next

    after <- lines[(marker + 1):length(lines)]
    after <- after[cumsum(nzchar(trimws(after))) > 0]  # drop leading blanks
    n_pipe <- which(!grepl("^\\s*\\|", after))[1] - 1
    if (is.na(n_pipe)) n_pipe <- length(after)
    if (n_pipe > 0) {
      return(list(table = paste(after[1:n_pipe], collapse = "\n"),
                  n_rows = as.integer(n_rows)))
    }
  }
  list(table = NA_character_, n_rows = NA_integer_)
}

make_soil_lab_section <- function(code) {
  lab    <- fetch_soil_lab_summary(code)
  lab_row <- filter(soil_lab, new_code == code)

  intro <- "- **Original source:** see [Database access](#database-access)"
  if (nrow(lab_row) == 1 && !is.na(lab_row$n_properties_available[[1]]) &&
      !is.na(lab_row$n_properties_standardized[[1]])) {
    themes <- str_split(lab_row$properties_themes[[1]], "\\s{2,}")[[1]]
    themes <- paste(themes[nzchar(trimws(themes))], collapse = ", ")
    intro <- paste0(
      if (!is.na(lab$n_rows)) paste0("- **Total samples:** ", format(lab$n_rows, big.mark = ","), "\n"),
      "- **Properties available (original):** ", lab_row$n_properties_available[[1]], "\n",
      "- **Properties standardized (OSSL):** ", lab_row$n_properties_standardized[[1]],
      " — summarized in **@tbl-soillab-", tolower(code), "** below\n",
      "- **Categories:** ", themes, "\n", intro
    )
  }

  table_html <- pipe_table_to_html(lab$table)
  if (is.na(table_html)) {
    return(paste0(intro, "\n\n_Detailed summary statistics not available for this dataset._"))
  }

  paste0(
    intro, "\n\n",
    '```{=html}\n<p class="ossl-tt-hint"><i class="bi bi-info-circle" aria-hidden="true"></i> ',
    'Hover over any OSSL code in the table below to see its full description.</p>\n```\n\n',
    "::: {#tbl-soillab-", tolower(code), "}\n\n",
    "```{=html}\n", table_html, "\n```\n\n",
    "Summary statistics (mean, SD, percentiles) for OSSL-standardized soil properties.\n\n:::"
  )
}

# ---------- Spectra ----------
make_spectra_section <- function(df_row, name) {
  if (nrow(df_row) == 0) return("")
  field <- function(label, col) {
    if (!col %in% names(df_row)) return(NULL)
    paste0("- **", label, ":** ", safe_value(df_row[[col]]))
  }
  lines <- c(
    field("Acquisition mode", "acquisition_mode"),
    field("Intensity", "intensity"),
    field("Original range", "original_range"),
    field("Standardized range", "standardized_range"),
    field("Instrument", "instrument"),
    field("Manufacturer", "manufacturer"),
    field("Instrument co-scans", "instrument_coscans"),
    field("Scan repeats", "scan_repeats"),
    field("Scan accessory", "scan_accessory"),
    field("Original resolution (cm^-1^)", "original_resolution_cm-1"),
    if (!"original_resolution_cm-1" %in% names(df_row)) field("Original resolution", "original_resolution"),
    field("Sample preparation", "sample_preparation"),
    field("Additional info", "additional_info")
  )
  plot_url <- safe_value(df_row$url_spectra_plot, "")
  paste0(section_heading("soundwave", name), "\n\n", paste(lines, collapse = "\n"), "\n",
         if (nzchar(plot_url)) paste0("\n### ", name, " plot\n\n![](", plot_url, ")\n"), "\n")
}

# ---------- Hero, stats, access, references ----------
make_hero <- function(r) {
  band <- if (is.na(r$hex_color)) "#f1f3f5" else lighten(r$hex_color, amount = 0.96)
  pill <- function(label, on) {
    paste0('<span class="ossl-pill ', if (on) "ossl-pill-on" else "ossl-pill-off", '">', label, '</span>')
  }
  ext <- r$extent
  ext <- if (nzchar(ext)) paste0(toupper(substr(ext, 1, 1)), substring(ext, 2)) else ""
  extent_text <- paste(c(ext, r$country)[nzchar(c(ext, r$country))], collapse = " — ")

  paste0(
    '<div class="ossl-hero" style="background: ', band, ';">\n',
    '  <div class="ossl-hero-logo"><img src="logo/', r$new_code, '.png" alt="', r$new_code, ' logo"></div>\n',
    '  <div class="ossl-hero-text">\n',
    '    <h1 class="ossl-hero-title">', r$new_code, '</h1>\n',
    '    <p class="ossl-hero-desc">', r$description, '</p>\n',
    '    <div class="ossl-hero-meta">\n',
    '      <div class="ossl-pill-row">',
    pill("VNIR", has_range(r$spectral_range, "vnir")),
    pill("NIR",  has_range(r$spectral_range, "nir")),
    pill("MIR",  has_range(r$spectral_range, "mir")), '</div>\n',
    '      <span class="ossl-meta-divider"></span>\n',
    '      <span class="ossl-meta-item"><i class="bi bi-globe-americas" aria-hidden="true"></i>',
    extent_text, '</span>\n',
    '    </div>\n  </div>\n</div>\n'
  )
}

make_quick_stats <- function(r) {
  stat <- function(icon, val, suffix = "") {
    if (!nzchar(val) || val == "Not available") return(NULL)
    paste0('<span class="ossl-stat-item"><i class="bi bi-', icon, '" aria-hidden="true"></i>',
           '<span class="ossl-stat-val">', val, '</span>', suffix, '</span>')
  }
  items <- c(stat("database", r$sample_size, " samples"),
             stat("calendar3", r$version_source),
             stat("file-earmark-text", safe_value(r[["license"]], "")))
  if (length(items) == 0) return("")
  paste0('<div class="ossl-quick-stats">\n  ', paste(items, collapse = "\n  "), '\n</div>\n')
}

nice_file_label <- function(f) {
  type <- case_when(
    grepl("visnir", f, ignore.case = TRUE)   ~ "VisNIR spectra",
    grepl("_nir", f, ignore.case = TRUE)     ~ "NIR spectra",
    grepl("_mir", f, ignore.case = TRUE)     ~ "MIR spectra",
    grepl("soillab", f, ignore.case = TRUE)  ~ "Soil lab measurements",
    grepl("soilsite", f, ignore.case = TRUE) ~ "Soil site metadata",
    TRUE ~ f
  )
  fmt <- case_when(
    grepl("\\.parquet$", f)  ~ "Parquet",
    grepl("\\.csv\\.gz$", f) ~ "CSV (gzip)",
    grepl("\\.csv$", f)      ~ "CSV",
    TRUE ~ "Data"
  )
  paste0(type, " — ", fmt)
}

make_database_access <- function(r) {
  contact <- safe_value(r$contact, "")
  email   <- safe_value(r$contact_email, "")
  url     <- safe_value(r$url, "")
  credits <- c(
    if (nzchar(contact) && contact != "Not available") paste0("- **Contact:** ", contact),
    if (nzchar(email) && email != "Not available") paste0("- **Email:** [", email, "](mailto:", email, ")"),
    if (nzchar(url) && url != "Not available") paste0("- **Original source:** <", url, ">")
  )

  files <- filter(dataset_files, dataset_code == r$new_code)
  file_block <- if (nrow(files) == 0) "No file listing available for this dataset.\n" else paste0(
    "**Available files**\n\n| Type | Filename | Link |\n|------|----------|------|\n",
    paste0("| ", nice_file_label(files$ossl_file), " | `", files$ossl_file,
           "` | [Download](", files$public_url, ") |", collapse = "\n"), "\n"
  )

  paste0(if (length(credits) > 0) paste0("Data originally provided by:\n\n",
                                         paste(credits, collapse = "\n"), "\n\n"),
         file_block)
}

make_references <- function(r) {
  refs <- vapply(paste0("relevant_publication_", 1:3),
                 function(col) safe_value(r[[col]], ""), character(1))
  refs <- refs[nzchar(refs) & refs != "Not available"]
  if (length(refs) == 0) return("No references listed.\n")
  paste0(seq_along(refs), ". [Publication ", seq_along(refs), "](", refs, ")", collapse = "\n")
}

# ---------- Clean Access sheet ----------
access <- access |>
  mutate(
    new_code       = fix_blank(new_code, "Unknown"),
    description    = fix_blank(description, "No description available."),
    version_source = fix_blank(version_source, "Not available"),
    sample_size    = fix_blank(sample_size, "Not available"),
    spectral_range = fix_blank(spectral_range, "Unknown"),
    extent         = fix_blank(extent),
    country        = if ("country" %in% names(access)) fix_blank(country) else "",
    map_url        = fix_blank(map_url, "Not available")
  ) |>
  left_join(logo_palette, by = "new_code")

for (s in c("soil_site", "soil_lab", "mir", "vnir", "nir")) {
  assign(s, mutate(get(s), new_code = fix_blank(new_code)))
}

# ---------- 1. cards.yml ----------
cards <- access |>
  transmute(
    order_id    = row_number(),
    title       = new_code,
    description = description,
    sample_size = sample_size,
    version     = version_source,
    extent      = fix_blank(extent, "Unknown"),
    has_vnir    = has_range(spectral_range, "vnir"),
    has_nir     = has_range(spectral_range, "nir"),
    has_mir     = has_range(spectral_range, "mir"),
    band_color  = "#f1f3f5",
    image       = paste0("datasets/logo/", new_code, ".png"),
    path        = paste0("datasets/", new_code, ".html"),
    categories  = map2(spectral_range, extent, function(spec, ext) {
      parts <- trimws(strsplit(spec, ",")[[1]])
      unique(c(paste0("Spectral: ", paste(parts, collapse = " & ")),
               paste0("Spectral: ", parts),
               paste0("Extent: ", fix_blank(trimws(ext), "Unknown"))))
    })
  )

write_yaml(transpose(cards), "datasets/cards.yml")
message("Wrote ", nrow(cards), " cards")

# ---------- 2. One .qmd per dataset ----------
for (i in seq_len(nrow(access))) {
  r    <- access[i, ]
  code <- r$new_code

  site_info <- fetch_soilsite_columns(code)
  site_text <- make_bullets(filter(soil_site, new_code == code))
  if (!is.null(site_info)) {
    site_text <- paste0(
      site_text, "\n",
      "- **Variables available (OSSL):** ", length(site_info$populated), " out of ", site_info$n_total,
      " — see [Database description](../db-desc.html#panel-soilsite) for full schema\n",
      "- **Populated columns:** ", paste0("`", site_info$populated, "`", collapse = ", ")
    )
  }

  qmd <- paste0(
'---
title: "', code, '"
format:
  html:
    toc: true
    toc-depth: 2
    css: ../styles/cards.css
    include-in-header:
      text: |
        <style>#title-block-header { display: none !important; }</style>
---

```{=html}
', make_hero(r), make_quick_stats(r), '
```

', section_heading("cloud-download", "Database access"), '

', make_database_access(r), '

', section_heading("geo-alt", "Map"), '

![](', r$map_url, ')

', section_heading("pin-map", "Soil site information"), '

', site_text, '

', section_heading("clipboard-data", "Soil laboratory information"), '

', make_soil_lab_section(code), '

', make_spectra_section(filter(mir, new_code == code), "MIR"),
   make_spectra_section(filter(vnir, new_code == code), "VNIR"),
   make_spectra_section(filter(nir, new_code == code), "NIR"),
   section_heading("journal-text", "References"), '

', make_references(r), '
')

  writeLines(qmd, file.path("datasets", paste0(code, ".qmd")))
  message("Page: ", code)
}
