
## Downloading internal tables

library("googledrive")
library("googlesheets4")

# FACT CIN folder id
listed.table <- googledrive::drive_ls(as_id("0AHDIWmLAj40_Uk9PVA"), pattern = "OSSL_tab1_soildata_coding")
ossl.soildata.coding <- listed.table[[1,"id"]]

# Checking metadata
googlesheets4::as_sheets_id(ossl.soildata.coding)

# Downloading edited names
ossl.level0.names.soilsite <- googlesheets4::read_sheet(ossl.soildata.coding, sheet = "ossl_level0_names_soilsite")
ossl.level0.names.mir <- googlesheets4::read_sheet(ossl.soildata.coding, sheet = "ossl_level0_names_mir")
ossl.level0.names.visnir <- googlesheets4::read_sheet(ossl.soildata.coding, sheet = "ossl_level0_names_visnir")
ossl.level0.names.soillab <- googlesheets4::read_sheet(ossl.soildata.coding, sheet = "ossl_level0_names_soillab")
ossl.level1.names.soillab <- googlesheets4::read_sheet(ossl.soildata.coding, sheet = "ossl_level1_soillab_harmonization")

# Saving to folder
getwd()
readr::write_csv(ossl.level0.names.soilsite, "./tabular/ossl_level0_names_soilsite.csv")
readr::write_csv(ossl.level0.names.mir, "./tabular/ossl_level0_names_mir.csv")
readr::write_csv(ossl.level0.names.visnir, "./tabular/ossl_level0_names_visnir.csv")
readr::write_csv(ossl.level0.names.soillab, "./tabular/ossl_level0_names_soillab.csv")
readr::write_csv(ossl.level1.names.soillab, "./tabular/ossl_level1_names_soillab.csv")
