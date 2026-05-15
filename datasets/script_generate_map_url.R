
library(googlesheets4)
library(dplyr)

# 1. Read the sheet
gs4_auth(email = "rzhi@woodwellclimate.org")
sheet_id <- "19PuiJx1mzNaFff4odODNzS6ZB72lcz9UbcVPWCt8Gz8"
access_data <- read_sheet(sheet_id, sheet = "Access")

# 2. Generate URLs
base_url   <- "https://raw.githubusercontent.com/soilspectroscopy/ossl-imports/main/dataset/"
sub_path <- "/README_files/figure-gfm/map-1.png"

access_updated <- access_data %>%
  mutate(
    generated_map_url = paste0(base_url, old_code, sub_path)
    )

# 3. Write back to Google sheet
range_write(
  ss = sheet_id,
  data = access_updated %>% select(map_url = generated_map_url),
  sheet = "Access",
  range = "U2",
  col_names = FALSE,
  reformat = FALSE
  
)

message ("Success! Google Sheet updated with standardized Map URLs.")





