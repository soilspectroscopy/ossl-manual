#install.packages("arrow")
library(googlesheets4)
library(dplyr)
library(purrr)
library(stringr)
library(readr)
library(httr)
library(colorspace)
library(arrow)

# ============================================================================
# 1. Authorize and read data sources
# ============================================================================
gs4_auth(email = "rzhi@woodwellclimate.org")

sheet_id <- "19PuiJx1mzNaFff4odODNzS6ZB72lcz9UbcVPWCt8Gz8"

access    <- read_sheet(sheet_id, sheet = "Access")
soil_site <- read_sheet(sheet_id, sheet = "Soil_site")
soil_lab  <- read_sheet(sheet_id, sheet = "Soil_lab")
mir       <- read_sheet(sheet_id, sheet = "MIR")
vnir      <- read_sheet(sheet_id, sheet = "VNIR")
nir       <- read_sheet(sheet_id, sheet = "NIR")

# OSSL property code descriptions (separate spreadsheet)
coding_sheet_id <- "1KnPj2eUqrAZ_5JzEyXzZ-qvK8h6EcwQwRlR2-FXnbqg"
ossl_codes_soillab <- read_sheet(coding_sheet_id,
                                 sheet = "ossl_level0_names_soillab")

dataset_files <- read_csv(
  "datasets/ossl_individual_datasets_urls_v1.3.csv",
  show_col_types = FALSE
)

# Canonical logo colors — keep hero banners in sync with the hexagon logos
logo_palette <- read_csv(
  "datasets/logo_color_palette.csv",
  show_col_types = FALSE
) %>%
  select(new_code, hex_color)

GITHUB_BASE <- "https://raw.githubusercontent.com/soilspectroscopy/ossl-imports/main/dataset"
GITHUB_VIEW <- "https://github.com/soilspectroscopy/ossl-imports/tree/main/dataset"

# ============================================================================
# 2. Helper functions
# ============================================================================
fix_blank <- function(x, default = "") {
  x <- as.character(x)
  x[is.na(x) | trimws(x) == ""] <- default
  x
}

safe_value <- function(x, default = "Not available") {
  if (length(x) == 0 || all(is.na(x)) || all(trimws(as.character(x)) == "")) {
    return(default)
  }
  as.character(x[[1]])
}

# ----- Cache directory for soilsite parquet files ---------------------------
soilsite_cache_dir <- "cache/soilsite"
if (!dir.exists(soilsite_cache_dir)) {
  dir.create(soilsite_cache_dir, recursive = TRUE)
}

# A column is "populated" if it has at least one non-NA, non-empty value.
is_populated_column <- function(col) {
  if (length(col) == 0) return(FALSE)
  if (is.numeric(col) || is.integer(col) || is.logical(col)) {
    return(any(!is.na(col)))
  }
  any(!is.na(col) & nzchar(trimws(as.character(col))))
}

# Fetch this dataset's soilsite parquet (with local caching) and return
# the total column count plus the list of populated column names.
fetch_soilsite_columns <- function(code, dataset_files) {
  url_row <- dataset_files |>
    filter(dataset_code == code,
           ossl_file    == "ossl_soilsite_v1.3.parquet")
  if (nrow(url_row) == 0) return(NULL)
  
  url        <- url_row$public_url[[1]]
  cache_path <- file.path(soilsite_cache_dir, paste0(code, "_soilsite.parquet"))
  
  if (!file.exists(cache_path)) {
    ok <- tryCatch({
      download.file(url, cache_path, mode = "wb", quiet = TRUE)
      TRUE
    }, error = function(e) {
      message("Could not download soilsite parquet for ", code, ": ", e$message)
      FALSE
    })
    if (!ok || !file.exists(cache_path)) return(NULL)
  }
  
  df <- tryCatch(
    arrow::read_parquet(cache_path),
    error = function(e) {
      message("Could not read soilsite parquet for ", code, ": ", e$message)
      NULL
    }
  )
  if (is.null(df) || nrow(df) == 0) return(NULL)
  
  list(
    total_columns     = ncol(df),
    populated_columns = names(df)[vapply(df, is_populated_column, logical(1))]
  )
}



# Escape special characters for safe inclusion in HTML attributes/text
html_escape <- function(x) {
  if (is.null(x) || length(x) == 0) return("")
  x <- as.character(x)
  if (is.na(x) || x == "NULL") return("")
  x <- gsub("&",  "&amp;",  x, fixed = TRUE)
  x <- gsub("<",  "&lt;",   x, fixed = TRUE)
  x <- gsub(">",  "&gt;",   x, fixed = TRUE)
  x <- gsub("\"", "&quot;", x, fixed = TRUE)
  x <- gsub("'",  "&#39;",  x, fixed = TRUE)
  x
}

# Build a named-list lookup: ossl_name -> list(analyte, description, unit, unit_description)
build_code_lookup <- function(df) {
  out <- list()
  for (i in seq_len(nrow(df))) {
    name <- trimws(as.character(df$ossl_name[[i]]))
    if (!is.na(name) && nchar(name) > 0) {
      out[[name]] <- list(
        analyte          = as.character(df$analyte[[i]]),
        method           = as.character(df$ossl_method[[i]]),
        unit             = as.character(df$ossl_unit[[i]])
      )
    }
  }
  out
}

# Build the HTML for one OSSL code with its tooltip popover
build_tooltip_span <- function(code, info) {
  analyte <- html_escape(info$analyte)
  method  <- html_escape(info$method)
  unit    <- html_escape(info$unit)
  
  paste0(
    '<span class="ossl-tt">', html_escape(code),
    '<span class="ossl-tt-pop">',
    if (nchar(analyte) > 0) paste0('<span class="tt-analyte">', analyte, '</span>') else '',
    if (nchar(method)  > 0) paste0('<span class="tt-desc">Method: <code>', method, '</code></span>') else '',
    if (nchar(unit)    > 0) paste0('<span class="tt-unit">Unit: <code>', unit, '</code></span>')   else '',
    '</span>',
    '</span>'
  )
}

# Parse a markdown pipe-table row into trimmed cell strings
parse_pipe_row <- function(line) {
  line <- trimws(line)
  line <- sub("^\\|", "", line)
  line <- sub("\\|$", "", line)
  cells <- strsplit(line, "|", fixed = TRUE)[[1]]
  trimws(cells)
}

# Detect alignment from a separator row like |:---|---:|:-:|
parse_alignments <- function(sep_cells) {
  vapply(sep_cells, function(s) {
    s <- trimws(s)
    left  <- startsWith(s, ":")
    right <- endsWith(s, ":")
    if (right && !left)      "right"
    else if (left && right)  "center"
    else                     "left"
  }, character(1), USE.NAMES = FALSE)
}

# Convert a markdown pipe table to an HTML table, injecting tooltips into the first column
convert_soil_lab_table_to_html <- function(table_md, lookup) {
  if (is.na(table_md) || nchar(table_md) == 0) return(NA_character_)
  
  lines <- strsplit(table_md, "\n", fixed = TRUE)[[1]]
  lines <- lines[grepl("^\\s*\\|", lines, perl = TRUE)]
  if (length(lines) < 3) return(table_md)  # need header + separator + 1+ data row
  
  header     <- parse_pipe_row(lines[1])
  sep_cells  <- parse_pipe_row(lines[2])
  alignments <- parse_alignments(sep_cells)
  data_lines <- lines[3:length(lines)]
  
  thead_html <- paste0(
    "<thead><tr>",
    paste0("<th style=\"text-align:", alignments, "\">",
           vapply(header, html_escape, character(1)), "</th>", collapse = ""),
    "</tr></thead>"
  )
  
  body_rows <- vapply(data_lines, function(line) {
    cells <- parse_pipe_row(line)
    if (length(cells) < length(header)) {
      cells <- c(cells, rep("", length(header) - length(cells)))
    }
    
    code <- cells[1]
    info <- lookup[[code]]
    first_html <- if (!is.null(info)) build_tooltip_span(code, info) else html_escape(code)
    
    rest_html <- paste0(
      "<td style=\"text-align:", alignments[-1], "\">",
      vapply(cells[-1], html_escape, character(1)),
      "</td>",
      collapse = ""
    )
    
    paste0(
      "<tr>",
      "<td style=\"text-align:", alignments[1], "\">", first_html, "</td>",
      rest_html,
      "</tr>"
    )
  }, character(1), USE.NAMES = FALSE)
  
  paste0(
    "<table class=\"soil-lab-table\">",
    thead_html,
    "<tbody>", paste(body_rows, collapse = ""), "</tbody>",
    "</table>"
  )
}




# Word-boundary match for spectral range names — so "vnir" doesn't false-match
# inside other text and "nir" doesn't match within "vnir".
has_range <- function(spec, range) {
  spec_lower <- tolower(fix_blank(spec, ""))
  grepl(paste0("\\b", range, "\\b"), spec_lower)
}

# Compute a pale background tint from the logo color (matches the cards page).
band_color_for <- function(hex_color) {
  if (is.na(hex_color) || trimws(hex_color) == "") return("#f1f3f5")
  tryCatch(
    colorspace::lighten(hex_color, amount = 0.96),
    error = function(e) "#f1f3f5"
  )
}

# Combine extent (e.g. "continental") with country (e.g. "Africa") into one
# display string used in the hero meta row.
extent_display <- function(extent, country) {
  ext <- safe_value(extent, "")
  cty <- safe_value(country, "")
  ext <- if (nchar(ext) > 0) paste0(toupper(substr(ext, 1, 1)),
                                    substr(ext, 2, nchar(ext))) else ""
  if (cty == "" || cty == "Not available") return(ext)
  if (ext == "") return(cty)
  paste0(ext, " — ", cty)
}

make_bullets_from_row <- function(df_row, exclude_cols = character()) {
  if (nrow(df_row) == 0) return("Not available.\n")
  cols <- setdiff(names(df_row), exclude_cols)
  vals <- lapply(cols, function(col) {
    value <- as.character(df_row[[col]][1])
    if (is.na(value) || trimws(value) == "") return(NULL)
    label <- gsub("_", " ", col)
    label <- paste0(toupper(substr(label, 1, 1)), substr(label, 2, nchar(label)))
    paste0("- **", label, ":** ", value)
  })
  vals <- vals[!vapply(vals, is.null, logical(1))]
  if (length(vals) == 0) return("Not available.\n")
  paste(vals, collapse = "\n")
}

# Section heading helper — pairs a Bootstrap Icon with the title.
section_heading <- function(icon, title) {
  paste0(
    '## <i class="bi bi-', icon,
    ' ossl-section-icon" aria-hidden="true"></i> ', title
  )
}

# Spectra section — returns empty string when the dataset has no data so the
# heading is also suppressed.
make_spectra_section <- function(df_row, section_name, icon = "soundwave") {
  if (nrow(df_row) == 0) return("")

  plot_url <- safe_value(df_row$url_spectra_plot, "")
  info_lines <- c(
    paste0("- **Acquisition mode:** ", safe_value(df_row$acquisition_mode)),
    paste0("- **Intensity:** ", safe_value(df_row$intensity)),
    paste0("- **Original range:** ", safe_value(df_row$original_range)),
    if ("standardized_range" %in% names(df_row))
      paste0("- **Standardized range:** ", safe_value(df_row$standardized_range)),
    paste0("- **Instrument:** ", safe_value(df_row$instrument)),
    paste0("- **Manufacturer:** ", safe_value(df_row$manufacturer)),
    if ("instrument_coscans" %in% names(df_row))
      paste0("- **Instrument co-scans:** ", safe_value(df_row$instrument_coscans)),
    if ("scan_repeats" %in% names(df_row))
      paste0("- **Scan repeats:** ", safe_value(df_row$scan_repeats)),
    paste0("- **Scan accessory:** ", safe_value(df_row$scan_accessory)),
    if ("original_resolution_cm-1" %in% names(df_row)) {
      paste0("- **Original resolution (cm^-1^):** ", safe_value(df_row[["original_resolution_cm-1"]]))
    } else if ("original_resolution" %in% names(df_row)) {
      paste0("- **Original resolution:** ", safe_value(df_row$original_resolution))
    },
    paste0("- **Sample preparation:** ", safe_value(df_row$sample_preparation)),
    paste0("- **Additional info:** ", safe_value(df_row$additional_info))
  )
  info_lines <- info_lines[!vapply(info_lines, is.null, logical(1))]

  plot_block <- if (!is.na(plot_url) && trimws(plot_url) != "") {
    paste0("\n### ", section_name, " plot\n\n![](", plot_url, ")\n")
  } else {
    "\n"
  }

  paste0(
    section_heading(icon, section_name), "\n\n",
    paste(info_lines, collapse = "\n"),
    "\n",
    plot_block, "\n"
  )
}

# ----- Hero banner ----------------------------------------------------------
make_hero <- function(code, description, hex_color,
                      has_vnir, has_nir, has_mir,
                      extent_text, logo_src) {

  band <- band_color_for(hex_color)

  pill <- function(label, active) {
    cls <- if (active) "ossl-pill ossl-pill-on" else "ossl-pill ossl-pill-off"
    paste0('<span class="', cls, '">', label, '</span>')
  }

  paste0(
    '<div class="ossl-hero" style="background: ', band, ';">\n',
    '  <div class="ossl-hero-logo">\n',
    '    <img src="', logo_src, '" alt="', code, ' logo">\n',
    '  </div>\n',
    '  <div class="ossl-hero-text">\n',
    '    <h1 class="ossl-hero-title">', code, '</h1>\n',
    '    <p class="ossl-hero-desc">', description, '</p>\n',
    '    <div class="ossl-hero-meta">\n',
    '      <div class="ossl-pill-row">\n',
    '        ', pill("VNIR", has_vnir), '\n',
    '        ', pill("NIR",  has_nir),  '\n',
    '        ', pill("MIR",  has_mir),  '\n',
    '      </div>\n',
    '      <span class="ossl-meta-divider"></span>\n',
    '      <span class="ossl-meta-item">',
        '<i class="bi bi-globe-americas" aria-hidden="true"></i>',
        extent_text, '</span>\n',
    '    </div>\n',
    '  </div>\n',
    '</div>\n'
  )
}

# ----- Quick-stats strip (sample size, version, license) --------------------
make_quick_stats <- function(row_access) {
  items <- list()

  sample_size <- safe_value(row_access$sample_size, "")
  if (sample_size != "" && sample_size != "Not available") {
    items[[length(items) + 1]] <- paste0(
      '<span class="ossl-stat-item"><i class="bi bi-database" aria-hidden="true"></i>',
      '<span class="ossl-stat-val">', sample_size, '</span> samples</span>'
    )
  }

  version <- safe_value(row_access$version_source, "")
  if (version != "" && version != "Not available") {
    items[[length(items) + 1]] <- paste0(
      '<span class="ossl-stat-item"><i class="bi bi-calendar3" aria-hidden="true"></i>',
      '<span class="ossl-stat-val">', version, '</span></span>'
    )
  }

  license <- if ("license" %in% names(row_access)) safe_value(row_access$license, "") else ""
  if (license != "" && license != "Not available") {
    items[[length(items) + 1]] <- paste0(
      '<span class="ossl-stat-item"><i class="bi bi-file-earmark-text" aria-hidden="true"></i>',
      '<span class="ossl-stat-val">', license, '</span></span>'
    )
  }

  if (length(items) == 0) return("")

  paste0(
    '<div class="ossl-quick-stats">\n  ',
    paste(unlist(items), collapse = "\n  "),
    '\n</div>\n'
  )
}


# ----- Parse the "Variable type: numeric" table from README text ------------
extract_soil_lab_table <- function(text) {
  lines <- strsplit(text, "\n", fixed = TRUE)[[1]]
  
  cleaned <- trimws(gsub("^[*#\\s]+|[*#\\s]+$", "", lines, perl = TRUE))
  marker_idx <- grep(
    "^Variable type:\\s*numeric\\s*:?$",
    cleaned, perl = TRUE, ignore.case = TRUE
  )
  if (length(marker_idx) == 0) return(NA_character_)
  marker_idx <- marker_idx[1]
  
  after <- lines[(marker_idx + 1):length(lines)]
  
  pipe_start <- NA_integer_
  for (i in seq_along(after)) {
    if (grepl("^\\s*\\|", after[i], perl = TRUE)) {
      pipe_start <- i; break
    }
    if (trimws(after[i]) != "") break
  }
  if (!is.na(pipe_start)) {
    table_lines <- character()
    for (i in pipe_start:length(after)) {
      if (grepl("^\\s*\\|", after[i], perl = TRUE)) {
        table_lines <- c(table_lines, after[i])
      } else break
    }
    if (length(table_lines) > 0) return(paste(table_lines, collapse = "\n"))
  }
  
  html_start <- grep("^\\s*<table", after, perl = TRUE, ignore.case = TRUE)
  html_end   <- grep("</table>",       after, perl = TRUE, ignore.case = TRUE)
  if (length(html_start) > 0 && length(html_end) > 0 && html_end[1] >= html_start[1]) {
    return(paste(after[html_start[1]:html_end[1]], collapse = "\n"))
  }
  
  NA_character_
}

# ----- Parse "Number of rows" from README text ------------------------------
extract_n_rows <- function(text) {
  m <- regmatches(
    text,
    regexpr("Number of rows[^0-9]*([0-9]+)", text, perl = TRUE)
  )
  if (length(m) > 0 && nchar(m[1]) > 0) {
    n <- regmatches(m[1], regexpr("[0-9]+", m[1]))
    if (length(n) > 0) return(as.integer(n))
  }
  NA_integer_
}

fetch_soil_lab_summary <- function(code) {
  candidates <- unique(c(code, sub("[0-9]+$", "", code)))
  for (folder in candidates) {
    url <- paste0(GITHUB_BASE, "/", folder, "/README.md")
    
    resp <- tryCatch(
      httr::GET(url, httr::timeout(20)),
      error = function(e) NULL
    )
    if (is.null(resp) || httr::status_code(resp) != 200) next
    
    text <- httr::content(resp, as = "text", encoding = "UTF-8")
    text <- gsub("\r\n?", "\n", text, perl = TRUE)
    
    table_md <- extract_soil_lab_table(text)
    n_rows   <- extract_n_rows(text)
    
    if (!is.na(table_md) && nchar(table_md) > 0) {
      return(list(table = table_md, n_rows = n_rows))
    }
  }
  list(table = NA_character_, n_rows = NA_integer_)
}


# ----- File-type label helper for download table ----------------------------
nice_file_label <- function(filename) {
  type <- case_when(
    grepl("visnir", filename, ignore.case = TRUE)  ~ "VisNIR spectra",
    grepl("_nir",   filename, ignore.case = TRUE)  ~ "NIR spectra",
    grepl("_mir",   filename, ignore.case = TRUE)  ~ "MIR spectra",
    grepl("soillab",  filename, ignore.case = TRUE) ~ "Soil lab measurements",
    grepl("soilsite", filename, ignore.case = TRUE) ~ "Soil site metadata",
    TRUE ~ filename
  )
  fmt <- case_when(
    grepl("\\.parquet$",  filename) ~ "Parquet",
    grepl("\\.csv\\.gz$", filename) ~ "CSV (gzip)",
    grepl("\\.csv$",      filename) ~ "CSV",
    TRUE ~ "Data"
  )
  paste0(type, " — ", fmt)
}

# ----- Database access block ------------------------------------------------
make_database_access <- function(row_access, code, dataset_files) {
  contact       <- safe_value(row_access$contact, NA_character_)
  contact_email <- safe_value(row_access$contact_email, NA_character_)
  source_url    <- safe_value(row_access$url, NA_character_)

  credit_lines <- character()
  if (!is.na(contact) && contact != "Not available")
    credit_lines <- c(credit_lines, paste0("- **Contact:** ", contact))
  if (!is.na(contact_email) && contact_email != "Not available")
    credit_lines <- c(credit_lines, paste0("- **Email:** [", contact_email,
                                            "](mailto:", contact_email, ")"))
  if (!is.na(source_url) && source_url != "Not available")
    credit_lines <- c(credit_lines, paste0("- **Original source:** <", source_url, ">"))

  credit_block <- if (length(credit_lines) > 0) {
    paste0("Data originally provided by:\n\n",
           paste(credit_lines, collapse = "\n"), "\n\n")
  } else ""

  files <- dataset_files %>% filter(dataset_code == code)
  file_block <- if (nrow(files) > 0) {
    rows <- vapply(seq_len(nrow(files)), function(i) {
      paste0("| ", nice_file_label(files$ossl_file[i]),
             " | `", files$ossl_file[i],
             "` | [Download](", files$public_url[i], ") |")
    }, character(1))
    paste0(
      "**Available files**\n\n",
      "| Type | Filename | Link |\n",
      "|------|----------|------|\n",
      paste(rows, collapse = "\n"), "\n"
    )
  } else {
    "No file listing available for this dataset.\n"
  }

  paste0(credit_block, file_block)
}

# ----- References section ---------------------------------------------------
make_references_section <- function(row_access) {
  refs <- c(
    safe_value(row_access$relevant_publication_1, ""),
    safe_value(row_access$relevant_publication_2, ""),
    safe_value(row_access$relevant_publication_3, "")
  )
  refs <- refs[refs != "" & refs != "Not available"]
  if (length(refs) == 0) return("No references listed.\n")

  lines <- vapply(seq_along(refs), function(i) {
    paste0(i, ". [Publication ", i, "](", refs[i], ")")
  }, character(1))
  paste(lines, collapse = "\n")
}

# ============================================================================
# 3. Clean key columns and join logo palette
# ============================================================================
access <- access %>%
  mutate(
    new_code       = fix_blank(new_code, "unknown"),
    description    = fix_blank(description, "No description available."),
    map_url        = fix_blank(map_url, "images/default-map.png"),
    version_source = fix_blank(version_source, "Not available"),
    sample_size    = fix_blank(sample_size, "Not available"),
    spectral_range = fix_blank(spectral_range, "Unknown"),
    extent         = fix_blank(extent, ""),
    country        = if ("country" %in% names(.)) fix_blank(country, "") else ""
  ) %>%
  left_join(logo_palette, by = "new_code")

soil_site <- soil_site %>% mutate(new_code = fix_blank(new_code))
soil_lab  <- soil_lab  %>% mutate(new_code = fix_blank(new_code))
mir       <- mir       %>% mutate(new_code = fix_blank(new_code))
vnir      <- vnir      %>% mutate(new_code = fix_blank(new_code))
nir       <- nir       %>% mutate(new_code = fix_blank(new_code))

# ============================================================================
# 4. Build one .qmd per dataset
# ============================================================================

# Build OSSL code -> description lookup once (reused for every dataset page)
code_lookup <- build_code_lookup(ossl_codes_soillab)

for (i in seq_len(nrow(access))) {

  row_access <- access[i, ]
  code <- row_access$new_code[[1]]

  row_site <- soil_site %>% filter(new_code == code)
  row_mir  <- mir       %>% filter(new_code == code)
  row_vnir <- vnir      %>% filter(new_code == code)
  row_nir  <- nir       %>% filter(new_code == code)

  map_url <- safe_value(row_access$map_url, "../images/default-map.png")
  if (map_url == "images/default-map.png") {
    map_url <- "../logo/missing-map.jpg"
  }

  # Hero banner inputs
  hero_html <- make_hero(
    code        = code,
    description = safe_value(row_access$description, "No description available."),
    hex_color   = safe_value(row_access$hex_color, ""),
    has_vnir    = has_range(row_access$spectral_range, "vnir"),
    has_nir     = has_range(row_access$spectral_range, "nir"),
    has_mir     = has_range(row_access$spectral_range, "mir"),
    extent_text = extent_display(row_access$extent, row_access$country),
    logo_src    = paste0("logo/", code, ".png")
  )

  quick_stats_html <- make_quick_stats(row_access)

  db_access_text <- make_database_access(row_access, code, dataset_files)

  # --- Fetch the skimr table and total sample count from README ---
  lab_info  <- fetch_soil_lab_summary(code)
  raw_table <- lab_info$table
  n_samples <- lab_info$n_rows
  
  # --- Soil lab framing paragraph from Soil_lab sheet ---
  lab_row <- soil_lab |> filter(new_code == code)
  
  lab_intro <- if (nrow(lab_row) == 1 &&
                   !is.na(lab_row$n_properties_standardized[[1]]) &&
                   !is.na(lab_row$n_properties_available[[1]])) {
    n_avail <- lab_row$n_properties_available[[1]]
    n_std   <- lab_row$n_properties_standardized[[1]]
    themes  <- lab_row$properties_themes[[1]]
    
    theme_list <- str_split(themes, "\\s{2,}")[[1]]
    theme_list <- theme_list[nchar(trimws(theme_list)) > 0]
    themes_fmt <- paste(theme_list, collapse = ", ")
    
    samples_bullet <- if (!is.na(n_samples)) {
      paste0("- **Total samples:** ", format(n_samples, big.mark = ","), "\n")
    } else ""
    
    paste0(
      samples_bullet,
      "- **Properties available (original):** ", n_avail, "\n",
      "- **Properties standardized (OSSL):** ", n_std,
      " — summarized in **@tbl-soillab-", tolower(code), "** below\n",
      "- **Categories:** ", themes_fmt, "\n",
      "- **Original source:** see [Database access](#database-access)"
    )
  } else {
    paste0(
      "- **Original source:** see [Database access](#database-access)"
    )
  }
  
  # --- Convert table to HTML with tooltip spans on OSSL codes ---
  raw_table_html <- convert_soil_lab_table_to_html(raw_table, code_lookup)
  
  soil_lab_text <- if (!is.na(raw_table_html) && nchar(raw_table_html) > 0) {
    hint <- paste0(
      '<p class="ossl-tt-hint">',
      '<i class="bi bi-info-circle" aria-hidden="true"></i> ',
      'Hover over any OSSL code in the table below to see its full description.',
      '</p>'
    )
    paste0(
      lab_intro, "\n\n",
      "```{=html}\n", hint, "\n```\n\n",
      "::: {#tbl-soillab-", tolower(code), "}\n\n",
      "```{=html}\n", raw_table_html, "\n```\n\n",
      "Summary statistics (mean, SD, percentiles) for OSSL-standardized soil properties.\n\n",
      ":::"
    )
  } else {
    paste0(lab_intro, "\n\n_Detailed summary statistics not available for this dataset._")
  }
  
  # Existing bullets from the Soil_site spreadsheet
  soil_site_spreadsheet <- make_bullets_from_row(
    row_site,
    exclude_cols = c("new_code", "old_code")
  )
  
  # New bullets derived from the dataset's soilsite parquet
  soilsite_info <- fetch_soilsite_columns(code, dataset_files)
  
  soil_site_parquet <- ""
  if (!is.null(soilsite_info)) {
    # Drop the metadata key column from the displayed list
    populated   <- setdiff(soilsite_info$populated_columns, "dataset.code_ascii_txt")
    n_total     <- soilsite_info$total_columns - 1  # exclude the same key column
    n_populated <- length(populated)
    
    # Render each code as inline `code` styling
    columns_text <- paste0("`", populated, "`", collapse = ", ")
    
    soil_site_parquet <- paste0(
      "- **Variables available (OSSL):** ", n_populated, " out of ", n_total,
      " — see [Database description](../db-desc.html#panel-soilsite) for full schema\n",
      "- **Populated columns:** ", columns_text
    )
  }
  
  soil_site_text <- if (nzchar(soil_site_parquet)) {
    paste0(soil_site_spreadsheet, "\n", soil_site_parquet)
  } else {
    soil_site_spreadsheet
  }
  

  mir_text  <- make_spectra_section(row_mir,  "MIR")
  vnir_text <- make_spectra_section(row_vnir, "VNIR")
  nir_text  <- make_spectra_section(row_nir,  "NIR")

  ref_text  <- make_references_section(row_access)

  qmd_text <- paste0(
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
', hero_html,
quick_stats_html, '
```

', section_heading("cloud-download", "Database access"), '

', db_access_text, '

', section_heading("geo-alt", "Map"), '

![](', map_url, ')

', section_heading("pin-map", "Soil site information"), '

', soil_site_text, '

', section_heading("clipboard-data", "Soil laboratory information"), '

', soil_lab_text, '

', mir_text,
   vnir_text,
   nir_text,

section_heading("journal-text", "References"), '

', ref_text, '
'
  )

  writeLines(qmd_text, file.path("datasets", paste0(code, ".qmd")))
  message("Created .qmd for: ", code)
}
