## Hexagon logos. Run only when new datasets are added to the Access sheet.
## Existing colors in tabular/logo_color_palette.csv are kept; new codes get a new color.

library("googlesheets4")
library("ggplot2")
library("hexSticker")
library("colorspace")
library("readr")

gs4_auth(email = "jsafanelli@woodwellclimate.org")
sheet_id <- "19PuiJx1mzNaFff4odODNzS6ZB72lcz9UbcVPWCt8Gz8"
codes <- read_sheet(sheet_id, sheet = "Access")$new_code

palette_file <- "tabular/logo_color_palette.csv"
palette <- read_csv(palette_file, show_col_types = FALSE)

new_codes <- setdiff(codes, palette$new_code)
if (length(new_codes) > 0) {
  
  n <- length(new_codes)
  
  palette <- rbind(palette, data.frame(
    new_code  = new_codes,
    hex_color = rgb(runif(n, 0, 90), runif(n, 0, 90), runif(n, 0, 90), maxColorValue = 255)
  ))
  
  write_csv(palette, palette_file)
  
}

df <- data.frame(x = 1:20, y = c(1, 3, 5, 6, 8, 7, 5, 4, 3, 4, 5, 6, 6, 5, 4, 4, 3, 3, 2, 2))

for (i in seq_len(nrow(palette))) {
  
  code <- palette$new_code[i]
  out  <- file.path("datasets/logo", paste0(code, ".png"))
  
  if (file.exists(out)) next

  dark  <- palette$hex_color[i]
  light <- lighten(dark, amount = 0.7)

  p <- ggplot(df, aes(x, y)) +
    stat_smooth(method = "gam", formula = y ~ s(x, bs = "cs"),
                se = FALSE, color = light, linewidth = 1) +
    theme_void()

  sticker(p, package = code, h_fill = dark, h_color = light, h_size = 1.5,
          p_size = 23, p_y = 1.3, s_x = 1.0, s_y = 0.75,
          s_width = 1.5, s_height = 0.55, filename = out)
  
  message("Logo: ", code)
  
}
