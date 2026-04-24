library(googlesheets4)
library(dplyr)
library(purrr)
library(stringr)
library(readr)

# ---------------------------
# 1. Authorize and read sheets
# ---------------------------
gs4_auth(email = "rzhi@woodwellclimate.org")

sheet_id <- "19PuiJx1mzNaFff4odODNzS6ZB72lcz9UbcVPWCt8Gz8"

access    <- read_sheet(sheet_id, sheet = "Access")
soil_lab  <- read_sheet(sheet_id, sheet = "Soil_lab")
soil_site <- read_sheet(sheet_id, sheet = "Soil_site")
mir       <- read_sheet(sheet_id, sheet = "MIR")
vnir      <- read_sheet(sheet_id, sheet = "VNIR")
nir       <- read_sheet(sheet_id, sheet = "NIR")

# ---------------------------
# 2. Helper functions
# ---------------------------
fix_blank <- function(x, default = "") {
  x <- as.character(x)
  x[is.na(x) | trimws(x) == ""] <- default
  x
}

collapse_tags <- function(x) {
  x <- fix_blank(x, "")
  x <- x[x != ""]
  paste(x, collapse = ", ")
}

safe_value <- function(x, default = "Not available") {
  if (length(x) == 0 || all(is.na(x)) || all(trimws(as.character(x)) == "")) {
    return(default)
  }
  as.character(x[[1]])
}

safe_markdown <- function(x, default = "Not available") {
  out <- safe_value(x, default)
  out <- gsub("\\|", "\\\\|", out)
  out
}

make_bullets_from_row <- function(df_row, exclude_cols = character()) {
  if (nrow(df_row) == 0) {
    return("Not available.\n")
  }
  
  cols <- setdiff(names(df_row), exclude_cols)
  vals <- lapply(cols, function(col) {
    value <- as.character(df_row[[col]][1])
    if (is.na(value) || trimws(value) == "") return(NULL)
    paste0("- **", gsub("_", " ", col), ":** ", value)
  })
  
  vals <- vals[!vapply(vals, is.null, logical(1))]
  if (length(vals) == 0) return("Not available.\n")
  paste(vals, collapse = "\n")
}

make_spectra_section <- function(df_row, section_name) {
  if (nrow(df_row) == 0) {
    return(paste0(
      "## ", section_name, "\n\n",
      "Not available.\n\n"
    ))
  }
  
  plot_url <- safe_value(df_row$url_spectra_plot, "")
  info_lines <- c(
    paste0("- **Acquisition mode:** ", safe_value(df_row$acquisition_mode)),
    paste0("- **Intensity:** ", safe_value(df_row$intensity)),
    paste0("- **Original range:** ", safe_value(df_row$original_range)),
    if ("standardized_range" %in% names(df_row)) paste0("- **Standardized range:** ", safe_value(df_row$standardized_range)) else NULL,
    paste0("- **Instrument:** ", safe_value(df_row$instrument)),
    paste0("- **Manufacturer:** ", safe_value(df_row$manufacturer)),
    if ("instrument_coscans" %in% names(df_row)) paste0("- **Instrument co-scans:** ", safe_value(df_row$instrument_coscans)) else NULL,
    if ("scan_repeats" %in% names(df_row)) paste0("- **Scan repeats:** ", safe_value(df_row$scan_repeats)) else NULL,
    paste0("- **Scan accessory:** ", safe_value(df_row$scan_accessory)),
    if ("original_resolution_cm-1" %in% names(df_row)) {
      paste0("- **Original resolution (cm^-1^):** ", safe_value(df_row[["original_resolution_cm-1"]]))
    } else if ("original_resolution" %in% names(df_row)) {
      paste0("- **Original resolution:** ", safe_value(df_row$original_resolution))
    } else NULL,
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
    "## ", section_name, "\n\n",
    paste(info_lines, collapse = "\n"),
    "\n",
    plot_block, "\n"
  )
}

# Build a database access link from dataset code

make_bucket_link <- function(code) {
  paste0("https://storage.googleapis.com/soilspec4gg-public/datasets/", code, "/")
}

# ---------------------------
# 3. Clean key columns
# ---------------------------
access <- access %>%
  mutate(
    new_code = fix_blank(new_code, "unknown"),
    description = fix_blank(description, "No description available."),
    map_url = fix_blank(map_url, "images/default-map.png"),
    version_source = fix_blank(version_source, "Not available"),
    sample_size = fix_blank(sample_size, "Not available"),
    spectral_range = fix_blank(spectral_range, "Unknown"),
    extent = fix_blank(extent, "Unknown")
  )

soil_lab <- soil_lab %>%
  mutate(new_code = fix_blank(new_code))

soil_site <- soil_site %>%
  mutate(new_code = fix_blank(new_code))

mir <- mir %>%
  mutate(new_code = fix_blank(new_code))

vnir <- vnir %>%
  mutate(new_code = fix_blank(new_code))

nir <- nir %>%
  mutate(new_code = fix_blank(new_code))


# ---------------------------
# 4. Create one qmd per dataset
# ---------------------------
for (i in seq_len(nrow(access))) {
  
  row_access <- access[i, ]
  code <- row_access$new_code[[1]]
  
  row_lab  <- soil_lab  %>% filter(new_code == code)
  row_site <- soil_site %>% filter(new_code == code)
  row_mir  <- mir       %>% filter(new_code == code)
  row_vnir <- vnir      %>% filter(new_code == code)
  row_nir  <- nir       %>% filter(new_code == code)
  
  # map path for dataset page
  map_url <- safe_value(row_access$map_url, "../images/default-map.png")
  
  # if your cards.yml uses images/default-map.png, detail pages inside /datasets/
  # usually need ../images/default-map.png
  if (map_url == "images/default-map.png") {
    map_url <- "../img/missing-map.jpg"
  }
  
  bucket_url <- make_bucket_link(code)
  
  # Soil lab: list all columns except key
  soil_lab_text <- make_bullets_from_row(
    row_lab,
    exclude_cols = c("new_code")
  )
  
  # Soil site: list all columns except key
  soil_site_text <- make_bullets_from_row(
    row_site,
    exclude_cols = c("new_code")
  )
  
  # Spectra sections
  mir_text  <- make_spectra_section(row_mir, "MIR")
  vnir_text <- make_spectra_section(row_vnir, "VNIR")
  nir_text  <- make_spectra_section(row_nir, "NIR")
  
  # References
  ref_text <- if ("reference" %in% names(row_access)) {
    safe_value(row_access$reference, "References will be added.")
  } else if ("references" %in% names(row_access)) {
    safe_value(row_access$references, "References will be added.")
  } else {
    "References will be added."
  }
  
  qmd_text <- paste0(
    '---
title: "', code, '"
format:
  html:
    toc: true
    toc-depth: 2
---

# ', code, '

', safe_value(row_access$description, "No description available."), '

## Overview

- **Sample size:** ', safe_value(row_access$sample_size), '
- **Version:** ', safe_value(row_access$version_source), '
- **Spectral range:** ', safe_value(row_access$spectral_range), '
- **Extent:** ', safe_value(row_access$extent), '

## Map

![](', map_url, ')

## Database access

[Open dataset files](', bucket_url, ')

## Soil laboratory information

', soil_lab_text, '

## Soil site information

', soil_site_text, '

', mir_text, '
', vnir_text, '
', nir_text, '

## References

', ref_text, '
'
  )
  
  writeLines(qmd_text, file.path("datasets", paste0(code, ".qmd")))
}






