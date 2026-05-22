library(googlesheets4)
library(yaml)
library(dplyr)
library(purrr)
library(colorspace)

# ---------- 1. Authorize and read the Google Sheet ----------
gs4_auth(email = "rzhi@woodwellclimate.org")

sheet_id <- "19PuiJx1mzNaFff4odODNzS6ZB72lcz9UbcVPWCt8Gz8"
raw_data <- read_sheet(sheet_id, sheet = "Access")

write.csv(raw_data, "datasets/OSSL_v2_listed_libraries.csv", row.names = FALSE)

# ---------- 2. Helpers ----------
logo_folder <- "datasets/logo/"

fix_blank <- function(x, default) {
  x <- as.character(x)
  x[is.na(x) | trimws(x) == ""] <- default
  x
}

# Detect spectral range with a word-boundary regex so "vnir" does not
# match the bare "nir" pill.
has_range <- function(spec_vec, range) {
  spec_lower <- tolower(fix_blank(spec_vec, ""))
  grepl(paste0("\\b", range, "\\b"), spec_lower)
}

# ---------- 3. Per-card band colors ----------

num_logos <- nrow(raw_data)

band_colors <- rep("#f1f3f5", num_logos) 

# ---------- 4. Map sheet columns to card fields ----------
formatted_cards <- raw_data %>%
  mutate(
    order_id   = row_number(),
    band_color = band_colors
  ) %>%
  transmute(
    order_id    = order_id,
    title       = fix_blank(new_code, "Untitled"),
    description = fix_blank(description, ""),
    sample_size = fix_blank(sample_size, ""),
    version     = fix_blank(version_source, ""),
    extent      = fix_blank(extent, "Unknown"),
    has_vnir    = has_range(spectral_range, "vnir"),
    has_nir     = has_range(spectral_range, "nir"),
    has_mir     = has_range(spectral_range, "mir"),
    band_color  = band_color,
    image       = paste0(logo_folder, new_code, ".png"),
    path        = paste0("datasets/", fix_blank(new_code, "unknown"), ".html"),
    categories = pmap(
      list(fix_blank(spectral_range, "Unknown"), fix_blank(extent, "Unknown")),
      function(spec, ext) {
        
        spec_combined <- spec %>% 
          trimws() %>% 
          gsub(",\\s*", " & ", .)
        
        spec_individual <- unlist(strsplit(as.character(spec), ","))
        spec_individual <- trimws(spec_individual)
        
        all_tags <- c(
          paste0("Spectral: ", spec_combined),   
          paste0("Spectral: ", spec_individual), 
          paste0("Extent: ", trimws(ext))      
        )
        
        unique(all_tags)
      }
    )
  )

# ---------- 5. Write cards.yml ----------
cards_list <- transpose(formatted_cards)
write_yaml(cards_list, "datasets/cards.yml")

message("Wrote ", nrow(formatted_cards), " cards to datasets/cards.yml")
