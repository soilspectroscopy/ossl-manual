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
logo_folder <- "datasets/logo/"

fix_blank <- function(x, default) {
  x <- as.character(x)
  x[is.na(x) | trimws(x) == ""] <- default
  x
}

formatted_cards <- raw_data %>%
  mutate(order_id = row_number()) %>%
  transmute(
    order_id = order_id,
    title = fix_blank(new_code, "Untitled"),
    description = fix_blank(description, ""),
    'Sample size' = fix_blank(sample_size, ""),
    Version = fix_blank(version_source, ""),
    image = paste0(logo_folder, new_code, ".png"),
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












