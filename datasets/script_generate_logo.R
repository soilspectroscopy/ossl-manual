# install.packages("colorspace")
# install.packages("hexSticker")
library("ggplot2")
library("hexSticker")
library("colorspace")
library("googlesheets4")

# 1. Authorize and Fetch Data from your Spreadsheet
gs4_auth(email = "rzhi@woodwellclimate.org")
sheet_id <- "19PuiJx1mzNaFff4odODNzS6ZB72lcz9UbcVPWCt8Gz8"
access_data <- read_sheet(sheet_id, sheet = "Access")

# Use the actual names from your sheet
dataset_names <- access_data$new_code
num_logos <- length(dataset_names)

set.seed(123) # For reproducibility

# 2. Color Logic (Random Dark RGB)
dark_shades <- rgb(
  runif(num_logos, 0, 90), 
  runif(num_logos, 0, 90), 
  runif(num_logos, 0, 90), 
  maxColorValue = 255
)


# Generate respective lighter shades
light_shades <- lighten(dark_shades, amount = 0.7)

# 3. Sample Data
df <- data.frame(x = 1:20, y = c(1, 3, 5, 6, 8, 7, 5, 4, 3, 4, 5, 6, 6, 5, 4, 4, 3, 3, 2, 2))

# 4. The Original Loop
for(i in 1:num_logos){
  
  idark  <- dark_shades[i]
  ilight <- light_shades[i]
  icode  <- dataset_names[i] # Uses name from Google Sheet
  
  p.line <- ggplot(df, aes(x, y)) +
    stat_smooth(method = "gam", 
                formula = y ~ s(x, bs = "cs"), 
                se = FALSE, 
                color = ilight, 
                linewidth = 1) +
    theme_void()
  
  sticker(p.line, 
          package = icode, 
          h_fill = idark, 
          h_color = ilight, 
          h_size = 1.5, 
          p_size = 23, 
          p_y = 1.3, 
          s_x = 1.0, 
          s_y = 0.75, 
          s_width = 1.5, 
          s_height = 0.55, 
          filename = paste0(file.path("datasets/logo", icode), ".png"))
}

# Save color scheme
color_db <- data.frame(new_code = dataset_names, hex_color = dark_shades)
write.csv(color_db, "datasets/logo_color_palette.csv")

