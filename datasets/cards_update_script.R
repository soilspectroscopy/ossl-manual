library(googlesheets4)
library(yaml)
library(dplyr)
library(purrr)

# 1. Authorize
gs4_auth(email = "rzhi@woodwellclimate.org")

# 2. Read the "Access" sheet from google spreadsheet
sheet_id <- "19PuiJx1mzNaFff4odODNzS6ZB72lcz9UbcVPWCt8Gz8"
raw_data <- read_sheet(sheet_id, sheet = "Access")

write.csv(raw_data, "datasets/OSSL_v2_listed_libraries.csv")

# 3. Map spreadsheet columns to cards.yml fields
default_image <- "datasets/img/missing_map.jpg"

fix_blank <- function(x, default) {
  x <- as.character(x)
  x[is.na(x) | trimws(x) == ""] <- default
  x
}

formatted_cards <- raw_data %>%
  transmute(
    title = fix_blank(new_code, "Untitled"),
    description = fix_blank(description, ""),
    sample_size = fix_blank(sample_size, ""),
    version = fix_blank(version_source, ""),
    image = fix_blank(map_url, default_image),
    path = paste0("datasets/", fix_blank(new_code, "unknown"), ".html"),
    categories = map2(
      fix_blank(spectral_range, "Unknown"),
      fix_blank(extent, "Unknown"),
      ~ c(
        paste0("Spectral: ", .x),
        paste0("Extent: ", .y)
      )
    )
  )


# 4. Write to cards.yml
cards_list <- transpose(formatted_cards)

write_yaml(cards_list, "datasets/cards.yml")












