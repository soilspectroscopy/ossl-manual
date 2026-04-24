
datasets_v1 <- c("KSSL", "ICRAF_ISRIC", "LUCAS", "AFSIS", "AFSIS2", "CAF", "NEON",
                 "Schiedung", "Garrett", "Serbia", "Neospectra") 

map_urls_v1 <- paste0("https://raw.githubusercontent.com/soilspectroscopy/ossl-imports/main/dataset/", 
                   datasets_v1, "/README_files/figure-gfm/map-1.png")

print(map_urls_v1)

datasets_v2 <- c("BESB", "Hungrian", "Austrian", "GEMAS", "Geocradle", "Martinique",
                 "TropicalFarm", "Korean", "South-India") 

map_urls_v2 <- paste0("https://raw.githubusercontent.com/soilspectroscopy/ossl-imports-internal/main/dataset/", 
                      datasets_v2, "/README_files/figure-commonmark/map-1.png")

print(map_urls_v2)

