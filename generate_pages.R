library(readr)
library(dplyr)
library(glue)
library(emoji)

# 1. Load spreadsheet data
df <- read_csv("datasets/libraries_metadata.csv")

# 2. Define a template for the .qmd files
# Use {column_name} to pull data from the spreadsheet
template <- '---
title: "{old_code}"
engine: knitr
---

## {old_code}

{description}

* :link: **Source:** {source}
* :copyright: **Data license:** {license}
* :round_pushpin: **Extent:** {extent}
* :label: **Spectral Range:** {spectral_range}
* :globe_with_meridians: **URL:** <{url_address}>
* :book: **Publication:** {relevant_publications}
'

# 3. Loop through every row and create a file
for(i in 1:nrow(df)) {
  row_clean <- df[i,] %>% 
    mutate(across(everything(), ~ifelse(is.na(.), "Not available", as.character(.))))
  
  file_content <- glue_data(row_clean, template)
  file_name <- paste0("datasets/", row$new_code, ".qmd")
  
  # FIX: Use readr::write_lines for consistent UTF-8 encoding
  readr::write_lines(file_content, file_name)
}

message("Success! 20 dataset pages generated in the 'datasets' folder.")