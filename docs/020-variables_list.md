# Database

::: {.rmdnote}
You are reading the work-in-progress of the SoilSpec4GG manual. This chapter is currently draft version, a peer-review publication is pending. You can find the polished first edition at <https://soilspectroscopy.github.io/ossl-manual/>.
:::

The github repository [ossl-imports](https://github.com/soilspectroscopy/ossl-imports) has all the importing codes for preparing and integrating new datasets into the OSSL. The folder [ossl-imports/dataset](https://github.com/soilspectroscopy/ossl-imports/tree/main/dataset) contains all the datasets separated by its name/code, with an internal `README` file describing in detail the steps necessary for preparing and standardizing the files into the OSSL format.

The original files are placed on an internal server to avoid the storage of big files in the github repository, but some of them can be found on persistent online repositories if they have a public license. Other original datasets that do not have a public license or are shared to this project with some restrictions will no be shared publicly. As we keep the original files in a local repository to run the importing notebooks (each `ossl-imports/dataset/../README.Rmd`), this operation can only be run at our internal server. New contributors are encouraged to host their files on a public repository and draft the importing step on github through pull requests. The final checks and consolidation, however, will be concluded on an internal server.

The `README` files follow a basic structure. Each one has a description of the dataset at the top of the notebook which links to the dataset source and references. An extended description is provided in the [OSSL-manual](https://soilspectroscopy.github.io/ossl-manual/soil-spectroscopy-tools-and-users.html#registered-soil-spectral-libraries) as well.

For preparing the import, the following subsections are defined:

- Basic description.
- Soil site information.
- Soil laboratory (wet chemistry) information.
- Mid-infrared (MIR) spectroscopy data (optional).
- Visible-near-infrared (VisNIR) spectroscopy data (optional).
- Quality control.
- References.

Each subsection has its own reading and processing functions, and the outputs can be joined using shared id columns. The output files share the same name and pattern but can be retrieved with different folder names, which are binded together in a final stage. The outputs are `ossl_soilsite_<version>.qs`, `ossl_soillab_<version>.qs`, `ossl_mir_<version>.qs`, `ossl_visnir_<version>.qs`. The version is adjusted in the recurring updates.

The contrasting methods used for analytically determining (wet chemistry) a given soil property has also been a subject of internal discussion in this project. Some global initiatives have been facing this same issue in their soil databases but there still no clear or full consensus on how to harmonize those different methods. This has been a topic of great discussion and research development at the [Global Soil Partnership’s Global Soil Laboratory Network (GLOSOLAN)](https://www.fao.org/global-soil-partnership/glosolan/en/).

In order to maximize transparency, for now, we have decided to produce two different levels for the OSSL database. `Level 0` takes into account the original methods employed in each dataset but tries to initially fit them to two reference lists: [KSSL Guidance – Laboratory Methods and Manuals](https://www.nrcs.usda.gov/resources/guides-and-instructions/kssl-guidance) and ISO standards. A copy of the KSSL procedures and coding scheme is archived in [ossl-imports](https://github.com/soilspectroscopy/ossl-imports/blob/main/out/kssl_procedures.csv).

If a reference method does not fall in any previous method, then we create a new variable sharing at least a common property and unit. A final harmonization takes place in the OSSL `Level 1`, where those common properties sharing different methods are converted to a target method using some publicly available transformation rule, or in the worst scenario, they are naively binded or kept separated to produce its specific model. All the implementations are documented in the [ossl-import](https://github.com/soilspectroscopy/ossl-imports/blob/main/out/ossl_level0_to_level1_soillab_harmonization.csv) repository.

The following subsections provide the OSSL variable names, types, description, and example. You can also find all this information in tabular format:

- [OSSL soil site data](./tabular/ossl_level0_names_soilsite.csv).
- [OSSL soil lab data (level 0)](./tabular/ossl_level0_names_soillab.csv).
- [OSSL soil lab data (level 1)](./tabular/ossl_level1_names_soillab.csv).
- [OSSL soil MIR data](./tabular/ossl_level0_names_mir.csv).
- [OSSL soil VisNIR data](./tabular/ossl_level0_names_visnir.csv).







## Soilsite data {#sites-table}

Observations and measurements at the site level. For the **site** table please use (at least) the following columns.


### dataset.code_ascii_txt
Description: OSSL dataset code.
Type: string.
Example: AFSIS1.SSL.

### id.layer_uuid_txt
Description: OSSL unique identifier.
Type: string.
Example: ded584d70bf0474202d30e575ae24784.

### id.layer_local_c
Description: Original observation identifier.
Type: string.
Example: icr072246.

### longitude.point_wgs84_dd
Description: Longitude in decimal degrees (WGS84, EPSG 4326).
Type: numeric.
Example: 15.6874916700.

### latitude.point_wgs84_dd
Description: Latitude in decimal degrees (WGS84, EPSG 4326).
Type: numeric.
Example: -7.37775000.

### layer.sequence_usda_uint16
Description: Layer sequence (incremented in depth).
Type: numeric.
Example: 1.

### layer.upper.depth_usda_cm
Description: Layer top depth in cm.
Type: numeric.
Example: 0.0.

### layer.lower.depth_usda_cm
Description: Layer bottom depth in cm.
Type: numeric.
Example: 20.0.

### observation.date.begin_iso.8601_yyyy.mm.dd
Description: Begin date of observation following YYYY-MM-DD format (ISO 8601).
Type: numeric.
Example: 2011-01-01.

### observation.date.end_iso.8601_yyyy.mm.dd
Description: End date of observation following YYYY-MM-DD format (ISO 8601).
Type: numeric.
Example: 2013-12-31.

### surveyor.title_utf8_txt
Description: Field surveyor name or organization.
Type: string.
Example: L.T.Desta.

### id.project_ascii_txt
Description: Project name.
Type: string.
Example: Africa Soil Information Service (AfSIS-1).

### id.location_olc_txt
Description: Unique Open Location Code with a precision of 6 decimal places in point coordinates.
Type: string.
Example: 6F4QJMCP+VX.

### layer.texture_usda_txt
Description: Texture description based on USDA classification.
Type: string.
Example: sand.

### pedon.taxa_usda_txt
Description: Soil classification based on the USDA Keys to Soil Taxonomy.
Type: string.
Example: Typic Kanhaplustalf.

### horizon.designation_usda_txt
Description: Soil horizon based on the USDA Keys to Soil Taxonomy.
Type: string.
Example: Ap.

### longitude.county_wgs84_dd
Description: County centroid, longitude in decimal degrees (WGS84, EPSG 4326).
Type: numeric.
Example: -96.688800.

### latitude.county_wgs84_dd
Description: County centroid, latitude in decimal degrees (WGS84, EPSG 4326).
Type: numeric.
Example: 40.78446.

### location.point.error_any_m
Description: Approximate point location error in m.
Type: numeric.
Example: 30.

### location.country_iso.3166_txt
Description: Country code following ISO 3166.
Type: string.
Example: NZL.

### observation.ogc.schema.title_ogc_txt
Description: Observation OGC schema title.
Type: string.
Example: Open Soil Spectroscopy Library.

### observation.ogc.schema_idn_url
Description: Observation OGC schema url.
Type: string.
Example: https://soilspectroscopy.github.io.

### surveyor.contact_ietf_email
Description: Surveyor contact email.
Type: string.
Example: afsis.info@africasoils.net.

### surveyor.address_utf8_txt
Description: Surveyor or institution address.
Type: string.
Example: ICRAF, PO Box 30677, Nairobi, 00100, Kenya.

### dataset.title_utf8_txt
Description: Dataset name.
Type: string.
Example: Africa Soil Information Service (AfSIS-1).

### dataset.owner_utf8_txt
Description: Name of of organization or person that is the responsible for the dataset.
Type: string.
Example: ICRAF, CROPNUTS, RRES.

### dataset.address_idn_url
Description: URL address of the dataset web page.
Type: string.
Example: https://www.isric.org/explore/ISRIC-collections.

### dataset.doi_idf_url
Description: Digital object identifier (DOI) url of the dataset.
Type: string.
Example: https://doi.org/10.1016/j.geodrs.2015.06.002.

### dataset.license.title_ascii_txt
Description: Dataset license.
Type: string.
Example: ODC Open Database License.

### dataset.license.address_idn_url
Description: Dataset license url.
Type: string.
Example: https://opendatacommons.org/licenses/odbl/.

### dataset.contact.name_utf8_txt
Description: Dataset contact name.
Type: string.
Example: Keith Shepherd.

### dataset.contact_ietf_email
Description: Dataset contact email.
Type: string.
Example: afsis.info@africasoils.net.

### id.dataset.site_ascii_txt
Description: Site identification.
Type: string.
Example: 203.

## Soillab data {#soillab-table}


### dataset.code_ascii_txt
Description: Dataset code used for internal reference. The analyte can be simply described as `OSSL dataset code`.
Unit: Imported into the OSSL as `txt`, i.e., text.
Type: string.
Example: AFSIS1.SSL.

### id.layer_uuid_txt
Description: Unique identifier. The analyte can be simply described as `OSSL unique identifier`.
Unit: Imported into the OSSL as `txt`, i.e., text.
Type: string.
Example: ded584d70bf0474202d30e575ae24784.

### acidity_usda.a795_cmolc.kg
Description: Extractable acidity, BaCl2-TEA at pH 8.2, is a measure of the amount of acid neutralized at a set pH. The analyte can be simply described as `Acidity, BaCl2-TEA Extractable, pH 8.2`.
Unit: Imported into the OSSL as `cmolc.kg`, i.e., centimoles of charge per kilogram of soil.
Type: numeric.
Example: 0.40000.
<img src="./hist_v1.2/hist_L0_acidity_usda.a795_cmolc.kg.png" heigth=100% width=100%>

### aggstb_usda.a1_w.pct
Description: Aggregate stability is the weight percent of 0.5 mm - 2 mm aggregates remaining after wet sieving.. The analyte can be simply described as `Aggregate Stability`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 74.
<img src="./hist_v1.2/hist_L0_aggstb_usda.a1_w.pct.png" heigth=100% width=100%>

### al.dith_usda.a65_w.pct
Description: Dithionite citrate extractable aluminum is an indicator of the amount of aluminum substituted for iron in iron oxides.. The analyte can be simply described as `Aluminum, Crystalline, Total Pedogenic Iron`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 0.13652.
<img src="./hist_v1.2/hist_L0_al.dith_usda.a65_w.pct.png" heigth=100% width=100%>

### al.ext_aquaregia_g.kg
Description: Exchangeable Al.. The analyte can be simply described as `Aluminum, Extractable, Aqua Regia`.
Unit: Imported into the OSSL as `g.kg`, i.e., grams per kilogram of soil.
Type: numeric.
Example: 42.9620831.
<img src="./hist_v1.2/hist_L0_al.ext_aquaregia_g.kg.png" heigth=100% width=100%>

### al.ext_usda.a1056_mg.kg
Description: Exchangeable Al.. The analyte can be simply described as `Aluminum, Extractable, Mehlich3`.
Unit: Imported into the OSSL as `mg.kg`, i.e., miligrams per kilogram of soil.
Type: numeric.
Example: 1270.00000.
<img src="./hist_v1.2/hist_L0_al.ext_usda.a1056_mg.kg.png" heigth=100% width=100%>

### al.ext_usda.a69_cmolc.kg
Description: Exchangeable Al.. The analyte can be simply described as `Aluminum, Extractable, KCl`.
Unit: Imported into the OSSL as `cmolc.kg`, i.e., centimoles of charge per kilogram of soil.
Type: numeric.
Example: 0.20000.
<img src="./hist_v1.2/hist_L0_al.ext_usda.a69_cmolc.kg.png" heigth=100% width=100%>

### al.ox_usda.a59_w.pct
Description: Ammonium oxalate extractable aluminum is an estimate of the total pedogenic Al, much of which may be in noncrystalline materials or complexed by organic matter.. The analyte can be simply described as `Aluminum, Amorphous, Total Non-Crystalline Iron`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 0.12951.
<img src="./hist_v1.2/hist_L0_al.ox_usda.a59_w.pct.png" heigth=100% width=100%>

### awc.33.1500kPa_usda.c80_w.frac
Description: The amount (fraction) of water released between 1/3 (33 kPa) and 15 (1500 kPa) bar tensions determined as gravimetric percent.. The analyte can be simply described as `Available Water Content, Difference 33-1500 kPa`.
Unit: Imported into the OSSL as `w.frac`, i.e., weight fraction.
Type: numeric.
Example: 0.08658.
<img src="./hist_v1.2/hist_L0_awc.33.1500kPa_usda.c80_w.frac.png" heigth=100% width=100%>

### b.ext_mel3_mg.kg
Description: Plant available B.. The analyte can be simply described as `Boron, Extractable, Mehlich3`.
Unit: Imported into the OSSL as `mg.kg`, i.e., miligrams per kilogram of soil.
Type: numeric.
Example: 0.00100000.
<img src="./hist_v1.2/hist_L0_b.ext_mel3_mg.kg.png" heigth=100% width=100%>

### bd_iso.11272_g.cm3
Description: Bulk density is the weight per unit volume of the fine earth fraction (<2 mm).. The analyte can be simply described as `Bulk Density, iso 11272`.
Unit: Imported into the OSSL as `g.cm3`, i.e., grams per cubic centimeter.
Type: numeric.
Example: 1.57100.
<img src="./hist_v1.2/hist_L0_bd_iso.11272_g.cm3.png" heigth=100% width=100%>

### bd_usda.a21_g.cm3
Description: Bulk density is the weight per unit volume of the fine earth fraction (<2 mm).. The analyte can be simply described as `Bulk Density, <2 mm fraction, Core`.
Unit: Imported into the OSSL as `g.cm3`, i.e., grams per cubic centimeter.
Type: numeric.
Example: 1.57100.
<img src="./hist_v1.2/hist_L0_bd_usda.a21_g.cm3.png" heigth=100% width=100%>

### bd_usda.a4_g.cm3
Description: Bulk density is the weight per unit volume of the fine earth fraction (<2 mm).. The analyte can be simply described as `Bulk Density, <2mm fraction, Clod`.
Unit: Imported into the OSSL as `g.cm3`, i.e., grams per cubic centimeter.
Type: numeric.
Example: 1.3477999.
<img src="./hist_v1.2/hist_L0_bd_usda.a4_g.cm3.png" heigth=100% width=100%>

### c.tot_iso.10694_w.pct
Description: Total carbon is a measure of all organic and inorganic carbon, including that found in carbonate minerals.. The analyte can be simply described as `Carbon, Total NCS, iso 10694`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 3.668778009.
<img src="./hist_v1.2/hist_L0_c.tot_iso.10694_w.pct.png" heigth=100% width=100%>

### c.tot_usda.a622_w.pct
Description: Total carbon is a measure of all organic and inorganic carbon, including that found in carbonate minerals.. The analyte can be simply described as `Carbon, Total NCS`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 1.55128592.
<img src="./hist_v1.2/hist_L0_c.tot_usda.a622_w.pct.png" heigth=100% width=100%>

### ca.ext_aquaregia_mg.kg
Description: Exchangeable or plant available Ca.. The analyte can be simply described as `Calcium, Extractable, Aqua Regia`.
Unit: Imported into the OSSL as `mg.kg`, i.e., miligrams per kilogram of soil.
Type: numeric.
Example: 368.535095.
<img src="./hist_v1.2/hist_L0_ca.ext_aquaregia_mg.kg.png" heigth=100% width=100%>

### ca.ext_usda.a1059_mg.kg
Description: Exchangeable or plant available Ca.. The analyte can be simply described as `Calcium, Extractable, Mehlich3`.
Unit: Imported into the OSSL as `mg.kg`, i.e., miligrams per kilogram of soil.
Type: numeric.
Example: 78.20000.
<img src="./hist_v1.2/hist_L0_ca.ext_usda.a1059_mg.kg.png" heigth=100% width=100%>

### ca.ext_usda.a722_cmolc.kg
Description: Exchangeable or plant available Ca.. The analyte can be simply described as `Calcium, Extractable, NH4OAc`.
Unit: Imported into the OSSL as `cmolc.kg`, i.e., centimoles of charge per kilogram of soil.
Type: numeric.
Example: 2.617060178.
<img src="./hist_v1.2/hist_L0_ca.ext_usda.a722_cmolc.kg.png" heigth=100% width=100%>

### caco3_iso.10693_w.pct
Description: Carbonate in the <2mm fraction is measured by CO2 evolution after acid treatment. It is reported as gravimetric percent CaCO3 on a <2 mm base, even though carbonates of Mg, Na, K, and Fe may be present and react with the acid.. The analyte can be simply described as `Carbonate, iso 10693`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 27.0.
<img src="./hist_v1.2/hist_L0_caco3_iso.10693_w.pct.png" heigth=100% width=100%>

### caco3_usda.a54_w.pct
Description: Carbonate in the <2mm fraction is measured by CO2 evolution after acid treatment. It is reported as gravimetric percent CaCO3 on a <2 mm base, even though carbonates of Mg, Na, K, and Fe may be present and react with the acid.. The analyte can be simply described as `Carbonate, <2mm Fraction`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 0.50000.
<img src="./hist_v1.2/hist_L0_caco3_usda.a54_w.pct.png" heigth=100% width=100%>

### cec_iso.11260_cmolc.kg
Description: Cation exchange capacity of a sample highly buffered at pH 7.0. It is reported as cmolc kg-1 (= meq per 100 grams) on a <2 mm base.. The analyte can be simply described as `CEC, pH 7.0, iso 11260`.
Unit: Imported into the OSSL as `cmolc.kg`, i.e., centimoles of charge per kilogram of soil.
Type: numeric.
Example: 37.8.
<img src="./hist_v1.2/hist_L0_cec_iso.11260_cmolc.kg.png" heigth=100% width=100%>

### cec_usda.a723_cmolc.kg
Description: Cation exchange capacity of a sample highly buffered at pH 7.0. It is reported on a <2 mm base.. The analyte can be simply described as `CEC, pH 7.0, NH4OAc, 2M KCl displacement`.
Unit: Imported into the OSSL as `cmolc.kg`, i.e., centimoles of charge per kilogram of soil.
Type: numeric.
Example: 6.6332171.
<img src="./hist_v1.2/hist_L0_cec_usda.a723_cmolc.kg.png" heigth=100% width=100%>

### cf_iso.11464_w.pct
Description: The gravimetric percentage of greater than 2 mm diameter particles reported on a whole soil base.. The analyte can be simply described as `Coarse Fragments, iso 11464`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 10.
<img src="./hist_v1.2/hist_L0_cf_iso.11464_w.pct.png" heigth=100% width=100%>

### cf_usda.c236_w.pct
Description: The gravimetric percentage of greater than 2 mm diameter particles reported on a whole soil base.. The analyte can be simply described as `Coarse Fragments, Greater 2mm`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 4.00000.
<img src="./hist_v1.2/hist_L0_cf_usda.c236_w.pct.png" heigth=100% width=100%>

### clay.tot_iso.11277_w.pct
Description: Total clay is the soil separate with <0.002 mm particle diameter. Clay size carbonate is included. It is reported on a <2 mm base.. The analyte can be simply described as `Clay, iso 11277`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 51.
<img src="./hist_v1.2/hist_L0_clay.tot_iso.11277_w.pct.png" heigth=100% width=100%>

### clay.tot_usda.a334_w.pct
Description: Total clay is the soil separate with <0.002 mm particle diameter. Clay size carbonate is included. It is reported on a <2 mm base.. The analyte can be simply described as `Clay`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 30.99000.
<img src="./hist_v1.2/hist_L0_clay.tot_usda.a334_w.pct.png" heigth=100% width=100%>

### cu.ext_usda.a1063_mg.kg
Description: Exchangeable or plant available Cu.. The analyte can be simply described as `Copper, Extractable, Mehlich3`.
Unit: Imported into the OSSL as `mg.kg`, i.e., miligrams per kilogram of soil.
Type: numeric.
Example: 0.5600000.
<img src="./hist_v1.2/hist_L0_cu.ext_usda.a1063_mg.kg.png" heigth=100% width=100%>

### ec_iso.11265_ds.m
Description: Electrical conductivity. It is reported of a 1:2 soil:water mixture. The analyte can be simply described as `Electrical Conductivity, iso 11265`.
Unit: Imported into the OSSL as `ds.m`, i.e., decisiemens per metre.
Type: numeric.
Example: 2.3350.
<img src="./hist_v1.2/hist_L0_ec_iso.11265_ds.m.png" heigth=100% width=100%>

### ec_usda.a364_ds.m
Description: Electrical conductivity. It is reported of a 1:2 soil:water mixture. The analyte can be simply described as `Electrical Conductivity, (w/w)`.
Unit: Imported into the OSSL as `ds.m`, i.e., decisiemens per metre.
Type: numeric.
Example: 0.03100.
<img src="./hist_v1.2/hist_L0_ec_usda.a364_ds.m.png" heigth=100% width=100%>

### efferv_usda.a479_class
Description: The visual effervescence of the prepared sample when treated with 1 N HCl.. The analyte can be simply described as `Effervescense, 1N HCl`.
Unit: Imported into the OSSL as `class`, i.e., class of visual interpretation.
Type: string.
Example: none.

### fe.dith_usda.a66_w.pct
Description: Dithionite citrate extractable iron is considered a general measure of total pedogenic iron.. The analyte can be simply described as `Iron, Crystalline, Total Pedogenic Iron`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 1.09028.
<img src="./hist_v1.2/hist_L0_fe.dith_usda.a66_w.pct.png" heigth=100% width=100%>

### fe.ext_aquaregia_g.kg
Description: Exchangeable or plant available Fe.. The analyte can be simply described as `Iron, Extractable, Aqua Regia`.
Unit: Imported into the OSSL as `g.kg`, i.e., grams per kilogram of soil.
Type: numeric.
Example: 71.9575342.
<img src="./hist_v1.2/hist_L0_fe.ext_aquaregia_g.kg.png" heigth=100% width=100%>

### fe.ext_usda.a1064_mg.kg
Description: Exchangeable or plant available Fe.. The analyte can be simply described as `Iron, Extractable, Mehlich3`.
Unit: Imported into the OSSL as `mg.kg`, i.e., miligrams per kilogram of soil.
Type: numeric.
Example: 182.00000.
<img src="./hist_v1.2/hist_L0_fe.ext_usda.a1064_mg.kg.png" heigth=100% width=100%>

### fe.ox_usda.a60_w.pct
Description: Ammonium oxalate extractable iron is considered a measure of the noncrystalline Fe in soils.. The analyte can be simply described as `Iron, Amorphous, Total Non-Crystalline Iron`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 0.15422.
<img src="./hist_v1.2/hist_L0_fe.ox_usda.a60_w.pct.png" heigth=100% width=100%>

### k.ext_aquaregia_mg.kg
Description: Exchangeable or plant available K.. The analyte can be simply described as `Sodium, Extractable, Aqua Regia`.
Unit: Imported into the OSSL as `mg.kg`, i.e., miligrams per kilogram of soil.
Type: numeric.
Example: 1781.400966.
<img src="./hist_v1.2/hist_L0_k.ext_aquaregia_mg.kg.png" heigth=100% width=100%>

### k.ext_usda.a1065_mg.kg
Description: Exchangeable or plant available K.. The analyte can be simply described as `Sodium, Extractable, Mehlich3`.
Unit: Imported into the OSSL as `mg.kg`, i.e., miligrams per kilogram of soil.
Type: numeric.
Example: 47.000000.
<img src="./hist_v1.2/hist_L0_k.ext_usda.a1065_mg.kg.png" heigth=100% width=100%>

### k.ext_usda.a725_cmolc.kg
Description: Exchangeable or plant available K.. The analyte can be simply described as `Sodium, Extractable, NH4OAc, 2M KCl displacement`.
Unit: Imported into the OSSL as `cmolc.kg`, i.e., centimoles of charge per kilogram of soil.
Type: numeric.
Example: 0.200688352.
<img src="./hist_v1.2/hist_L0_k.ext_usda.a725_cmolc.kg.png" heigth=100% width=100%>

### mg.ext_aquaregia_mg.kg
Description: Exchangeable or plant available Mg.. The analyte can be simply described as `Magnesium, Extractable, Aqua Regia`.
Unit: Imported into the OSSL as `mg.kg`, i.e., miligrams per kilogram of soil.
Type: numeric.
Example: 710.429099.
<img src="./hist_v1.2/hist_L0_mg.ext_aquaregia_mg.kg.png" heigth=100% width=100%>

### mg.ext_usda.a1066_mg.kg
Description: Exchangeable or plant available Mg.. The analyte can be simply described as `Magnesium, Extractable, Mehlich3`.
Unit: Imported into the OSSL as `mg.kg`, i.e., miligrams per kilogram of soil.
Type: numeric.
Example: 19.600000.
<img src="./hist_v1.2/hist_L0_mg.ext_usda.a1066_mg.kg.png" heigth=100% width=100%>

### mg.ext_usda.a724_cmolc.kg
Description: Exchangeable or plant available Mg.. The analyte can be simply described as `Magnesium, Extractable, NH4OAc, 2M KCl displacement`.
Unit: Imported into the OSSL as `cmolc.kg`, i.e., centimoles of charge per kilogram of soil.
Type: numeric.
Example: 1.81655342.
<img src="./hist_v1.2/hist_L0_mg.ext_usda.a724_cmolc.kg.png" heigth=100% width=100%>

### mn.ext_aquaregia_mg.kg
Description: Exchangeable or plant available Mn.. The analyte can be simply described as `Manganese, Extractable, Aqua Regia`.
Unit: Imported into the OSSL as `mg.kg`, i.e., miligrams per kilogram of soil.
Type: numeric.
Example: 497.300369.
<img src="./hist_v1.2/hist_L0_mn.ext_aquaregia_mg.kg.png" heigth=100% width=100%>

### mn.ext_usda.a1067_mg.kg
Description: Exchangeable or plant available Mn.. The analyte can be simply described as `Manganese, Extractable, Mehlich3`.
Unit: Imported into the OSSL as `mg.kg`, i.e., miligrams per kilogram of soil.
Type: numeric.
Example: 23.10000000.
<img src="./hist_v1.2/hist_L0_mn.ext_usda.a1067_mg.kg.png" heigth=100% width=100%>

### mn.ext_usda.a70_mg.kg
Description: Exchangeable or plant available Mn.. The analyte can be simply described as `Manganese, Extractable, KCl`.
Unit: Imported into the OSSL as `mg.kg`, i.e., miligrams per kilogram of soil.
Type: numeric.
Example: 0.62569.
<img src="./hist_v1.2/hist_L0_mn.ext_usda.a70_mg.kg.png" heigth=100% width=100%>

### n.tot_iso.11261_w.pct
Description: Total nitrogen is a measure of all organic and inorganic nitrogen.. The analyte can be simply described as `Nitrogen, Total NCS, iso 11261`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 0.25.
<img src="./hist_v1.2/hist_L0_n.tot_iso.11261_w.pct.png" heigth=100% width=100%>

### n.tot_iso.13878_w.pct
Description: Total nitrogen is a measure of all organic and inorganic nitrogen.. The analyte can be simply described as `Nitrogen, Total NCS, iso 13878`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 0.089.
<img src="./hist_v1.2/hist_L0_n.tot_iso.13878_w.pct.png" heigth=100% width=100%>

### n.tot_usda.a623_w.pct
Description: Total nitrogen is a measure of all organic and inorganic nitrogen.. The analyte can be simply described as `Nitrogen, Total NCS`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 0.079766974.
<img src="./hist_v1.2/hist_L0_n.tot_usda.a623_w.pct.png" heigth=100% width=100%>

### na.ext_aquaregia_mg.kg
Description: Exchangeable or plant availableNa.. The analyte can be simply described as `Potassium, Extractable, Aqua Regia`.
Unit: Imported into the OSSL as `mg.kg`, i.e., miligrams per kilogram of soil.
Type: numeric.
Example: 75.986312.
<img src="./hist_v1.2/hist_L0_na.ext_aquaregia_mg.kg.png" heigth=100% width=100%>

### na.ext_usda.a1068_mg.kg
Description: Exchangeable or plant availableNa.. The analyte can be simply described as `Potassium, Extractable, Mehlich3`.
Unit: Imported into the OSSL as `mg.kg`, i.e., miligrams per kilogram of soil.
Type: numeric.
Example: 17.800000.
<img src="./hist_v1.2/hist_L0_na.ext_usda.a1068_mg.kg.png" heigth=100% width=100%>

### na.ext_usda.a726_cmolc.kg
Description: Exchangeable or plant availableNa.. The analyte can be simply described as `Potassium, Extractable, NH4OAc, 2M KCl displacement`.
Unit: Imported into the OSSL as `cmolc.kg`, i.e., centimoles of charge per kilogram of soil.
Type: numeric.
Example: 0.124398521.
<img src="./hist_v1.2/hist_L0_na.ext_usda.a726_cmolc.kg.png" heigth=100% width=100%>

### oc_iso.10694_w.pct
Description: Estimated Organic Carbon based on Total C. The analyte can be simply described as `Organic Carbon, iso 10694`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 2.05000000.
<img src="./hist_v1.2/hist_L0_oc_iso.10694_w.pct.png" heigth=100% width=100%>

### oc_usda.c1059_w.pct
Description: Estimated Organic Carbon based on Total C. The analyte can be simply described as `Organic Carbon, Total C without CaCO3, N prep`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 1.50336492.
<img src="./hist_v1.2/hist_L0_oc_usda.c1059_w.pct.png" heigth=100% width=100%>

### oc_usda.c729_w.pct
Description: Estimated Organic Carbon based on Total C. The analyte can be simply described as `Organic Carbon, Total C without CaCO3, S prep`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 2.9100.
<img src="./hist_v1.2/hist_L0_oc_usda.c729_w.pct.png" heigth=100% width=100%>

### p.ext_aquaregia_mg.kg
Description: Plant available P.. The analyte can be simply described as `Phosphorus, Extractable, Aqua Regia`.
Unit: Imported into the OSSL as `mg.kg`, i.e., miligrams per kilogram of soil.
Type: numeric.
Example: 608.30492.
<img src="./hist_v1.2/hist_L0_p.ext_aquaregia_mg.kg.png" heigth=100% width=100%>

### p.ext_iso.11263_mg.kg
Description: Plant available P.. The analyte can be simply described as `Phosphorus, Extractable, iso 11263`.
Unit: Imported into the OSSL as `mg.kg`, i.e., miligrams per kilogram of soil.
Type: numeric.
Example: 72.4.
<img src="./hist_v1.2/hist_L0_p.ext_iso.11263_mg.kg.png" heigth=100% width=100%>

### p.ext_usda.a1070_mg.kg
Description: Plant available P.. The analyte can be simply described as `Phosphorus, Extractable, Mehlich3`.
Unit: Imported into the OSSL as `mg.kg`, i.e., miligrams per kilogram of soil.
Type: numeric.
Example: 3.44739.
<img src="./hist_v1.2/hist_L0_p.ext_usda.a1070_mg.kg.png" heigth=100% width=100%>

### p.ext_usda.a270_mg.kg
Description: Plant available P.. The analyte can be simply described as `Phosphorus, Extractable, Bray1`.
Unit: Imported into the OSSL as `mg.kg`, i.e., miligrams per kilogram of soil.
Type: numeric.
Example: 50.5348939.
<img src="./hist_v1.2/hist_L0_p.ext_usda.a270_mg.kg.png" heigth=100% width=100%>

### p.ext_usda.a274_mg.kg
Description: Plant available P.. The analyte can be simply described as `Phosphorus, Extractable, Olsen`.
Unit: Imported into the OSSL as `mg.kg`, i.e., miligrams per kilogram of soil.
Type: numeric.
Example: 17.23518992.
<img src="./hist_v1.2/hist_L0_p.ext_usda.a274_mg.kg.png" heigth=100% width=100%>

### p.ext_usda.a652_mg.kg
Description: Plant available P.. The analyte can be simply described as `Phosphorus, Extractable, Mehlich3`.
Unit: Imported into the OSSL as `mg.kg`, i.e., miligrams per kilogram of soil.
Type: numeric.
Example: 9.770000.
<img src="./hist_v1.2/hist_L0_p.ext_usda.a652_mg.kg.png" heigth=100% width=100%>

### ph.cacl2_iso.10390_index
Description: pH of a sample measured in 0.01 M CaCl2 at a 1:2 soil:solution ratio.. The analyte can be simply described as `pH, 1:2 Soil-CaCl2 Suspension, iso 10390`.
Unit: Imported into the OSSL as `index`, i.e., negative logarithm of the hydrogen ion concentration.
Type: numeric.
Example: 7.24.
<img src="./hist_v1.2/hist_L0_ph.cacl2_iso.10390_index.png" heigth=100% width=100%>

### ph.cacl2_usda.a477_index
Description: pH of a sample measured in 0.01 M CaCl2 at a 1:2 soil:solution ratio.. The analyte can be simply described as `pH, 1:2 Soil-CaCl2 Suspension, 0.01 M CaCl2`.
Unit: Imported into the OSSL as `index`, i.e., negative logarithm of the hydrogen ion concentration.
Type: numeric.
Example: 5.40.
<img src="./hist_v1.2/hist_L0_ph.cacl2_usda.a477_index.png" heigth=100% width=100%>

### ph.cacl2_usda.a481_index
Description: pH of a sample measured in 0.01 M CaCl2 at a 1:2 soil:solution ratio.. The analyte can be simply described as `pH, 1:2 Soil-CaCl2 Suspension`.
Unit: Imported into the OSSL as `index`, i.e., negative logarithm of the hydrogen ion concentration.
Type: numeric.
Example: 6.40000.
<img src="./hist_v1.2/hist_L0_ph.cacl2_usda.a481_index.png" heigth=100% width=100%>

### ph.h2o_iso.10390_index
Description: pH of the 1:1 soil:water suspension.. The analyte can be simply described as `pH, 1:1 Soil-Water Suspension, iso 10390`.
Unit: Imported into the OSSL as `index`, i.e., negative logarithm of the hydrogen ion concentration.
Type: numeric.
Example: 7.64.
<img src="./hist_v1.2/hist_L0_ph.h2o_iso.10390_index.png" heigth=100% width=100%>

### ph.h2o_usda.a268_index
Description: pH of the 1:1 soil:water suspension.. The analyte can be simply described as `pH, 1:1 Soil-Water Suspension`.
Unit: Imported into the OSSL as `index`, i.e., negative logarithm of the hydrogen ion concentration.
Type: numeric.
Example: 5.10000.
<img src="./hist_v1.2/hist_L0_ph.h2o_usda.a268_index.png" heigth=100% width=100%>

### s.ext_mel3_mg.kg
Description: Exchangeable or plant available S.. The analyte can be simply described as `Sulphur, Extractable, Mehlich3`.
Unit: Imported into the OSSL as `mg.kg`, i.e., miligrams per kilogram of soil.
Type: numeric.
Example: 16.800.
<img src="./hist_v1.2/hist_L0_s.ext_mel3_mg.kg.png" heigth=100% width=100%>

### s.tot_usda.a624_w.pct
Description: Total sulfur is a measure of all organic and inorganic sulfur, including that found in sulfide minerals.. The analyte can be simply described as `Sulfur, Total NCS`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 0.03569.
<img src="./hist_v1.2/hist_L0_s.tot_usda.a624_w.pct.png" heigth=100% width=100%>

### sand.tot_iso.11277_w.pct
Description: Total sand is the soil separate with 0.05 to 2.0 mm particle diameter. It is reported on a <2 mm base.. The analyte can be simply described as `Sand, Total, iso 11277`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 9.
<img src="./hist_v1.2/hist_L0_sand.tot_iso.11277_w.pct.png" heigth=100% width=100%>

### sand.tot_usda.c405_w.pct
Description: Total sand is the soil separate with 0.05 to 2.0 mm particle diameter. It is reported on a <2 mm base.. The analyte can be simply described as `Sand, Total, N prep`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 79.4.
<img src="./hist_v1.2/hist_L0_sand.tot_usda.c405_w.pct.png" heigth=100% width=100%>

### sand.tot_usda.c60_w.pct
Description: Total sand is the soil separate with 0.05 to 2.0 mm particle diameter. It is reported on a <2 mm base.. The analyte can be simply described as `Sand, Total, S prep`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 50.37000.
<img src="./hist_v1.2/hist_L0_sand.tot_usda.c60_w.pct.png" heigth=100% width=100%>

### silt.tot_iso.11277_w.pct
Description: Total silt is the soil separate with 0.002 to 0.05 mm particle size. It is reported on a <2 mm base.. The analyte can be simply described as `Silt, Total, iso 11277`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 40.
<img src="./hist_v1.2/hist_L0_silt.tot_iso.11277_w.pct.png" heigth=100% width=100%>

### silt.tot_usda.c407_w.pct
Description: Total silt is the soil separate with 0.002 to 0.05 mm particle size. It is reported on a <2 mm base.. The analyte can be simply described as `Silt, Total, N prep`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 18.2.
<img src="./hist_v1.2/hist_L0_silt.tot_usda.c407_w.pct.png" heigth=100% width=100%>

### silt.tot_usda.c62_w.pct
Description: Total silt is the soil separate with 0.002 to 0.05 mm particle size. It is reported on a <2 mm base.. The analyte can be simply described as `Silt, Total, S prep`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 18.64000.
<img src="./hist_v1.2/hist_L0_silt.tot_usda.c62_w.pct.png" heigth=100% width=100%>

### wr.10kPa_usda.a414_w.pct
Description: The gravimetric percent water after equilibration at 1/10 bar (10 kPa) water tension.. The analyte can be simply described as `Water Retention, 1/10 Bar (10 kPa)`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 10.852961.
<img src="./hist_v1.2/hist_L0_wr.10kPa_usda.a414_w.pct.png" heigth=100% width=100%>

### wr.10kPa_usda.a8_w.pct
Description: The gravimetric percent water after equilibration at 1/10 bar (10 kPa) water tension.. The analyte can be simply described as `Water Retention, 1/10 Bar (10 kPa), Clod`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 23.00000.
<img src="./hist_v1.2/hist_L0_wr.10kPa_usda.a8_w.pct.png" heigth=100% width=100%>

### wr.1500kPa_usda.a417_w.pct
Description: The gravimetric percent water after equilibration at 15 bar (1500 kPa) water tension.. The analyte can be simply described as `Water Retention, 15 Bar (1500 kPa)`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 3.000000.
<img src="./hist_v1.2/hist_L0_wr.1500kPa_usda.a417_w.pct.png" heigth=100% width=100%>

### wr.33kPa_usda.a415_w.pct
Description: The gravimetric percent water after equilibration at 1/3 bar (33 kPa) water tension.. The analyte can be simply described as `Water Retention, 1/3 Bar (33 kPa)`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 29.17023.
<img src="./hist_v1.2/hist_L0_wr.33kPa_usda.a415_w.pct.png" heigth=100% width=100%>

### wr.33kPa_usda.a9_w.pct
Description: The gravimetric percent water after equilibration at 1/3 bar (33 kPa) water tension.. The analyte can be simply described as `Water Retention, 1/3 Bar (33 kPa), Clod`.
Unit: Imported into the OSSL as `w.pct`, i.e., weight percent.
Type: numeric.
Example: 18.20000.
<img src="./hist_v1.2/hist_L0_wr.33kPa_usda.a9_w.pct.png" heigth=100% width=100%>

### zn.ext_usda.a1073_mg.kg
Description: Exchangeable or plant available Zn.. The analyte can be simply described as `Zinc, Extractable, Mehlich3`.
Unit: Imported into the OSSL as `mg.kg`, i.e., miligrams per kilogram of soil.
Type: numeric.
Example: 1.0300000.
<img src="./hist_v1.2/hist_L0_zn.ext_usda.a1073_mg.kg.png" heigth=100% width=100%>

## MIR scans {#mir-table}

Middle-infrared (MIR) spectra is provided in absorbance units per wavenumber, with values usually ranging between 0 and 3. The spectral range imported into the OSSL falls between 600 and 4000 cm<sup>-1</sup>, with an interval of 2 cm<sup>-1</sup>. All datasets are harmonized to this specification.

One can convert reflectance (R) values to absorbance units (A) as `A = log10(1/R)`, or backtransform with `R = 1/(10^A)`. Similarly, wavenumber (WN, in cm<sup>-1</sup>) can be converted to wavelength (WL, in nm) with `WN = 1/(WL*10000000)`, or backtransform with `WL = 1/(WL*10000000)`. The factor 10M is used to convert cm to nm.


### id.layer_uuid_txt
Description: OSSL unique identifier.
Type: string.
Example: 8585028b0344511c951fc0298b5ab3a8.

### id.scan_local_c
Description: Original scan identifier.
Type: string.
Example: icr021044.

### scan.mir.date.begin_iso.8601_yyyy.mm.dd
Description: Begin date of scanning following YYYY-MM-DD format (ISO 8601).
Type: numeric.
Example: 2009-01-01.

### scan.mir.date.end_iso.8601_yyyy.mm.dd
Description: Begin date of scanning following YYYY-MM-DD format (ISO 8601).
Type: numeric.
Example: 2013-12-31.

### scan.mir.model.name_utf8_txt
Description: MIR instrument manufacturer, model and accessory (if any).
Type: string.
Example: Bruker Tensor 27 with HTS-XT accessory.

### scan.mir.model.code_any_txt
Description: MIR instrument coding.
Type: string.
Example: Bruker_Tensor_27.HTS.XT.

### scan.mir.method.optics_any_txt
Description: Metadata information related to instrument optics and measurements.
Type: string.
Example: KBr beamsplitter; DTGS detector.

### scan.mir.method.preparation_any_txt
Description: Soil sample preparation before scanning.
Type: string.
Example: Finely ground <80 mesh.

### scan.mir.license.title_ascii_txt
Description: Dataset scans license.
Type: string.
Example: CC-BY.

### scan.mir.license.address_idn_url
Description: Dataset scans license url.
Type: string.
Example: https://creativecommons.org/licenses/by/4.0/.

### scan.mir.doi_idf_url
Description: Digital object identifier (DOI) url of the dataset scans.
Type: string.
Example: https://doi.org/10.34725/DVN/QXCWP1.

### scan.mir.contact.name_utf8_txt
Description: Dataset scans contact name.
Type: string.
Example: Vagen, Tor-Gunnar (World Agroforestry).

### scan.mir.contact.email_ietf_txt
Description: Dataset scans contact email.
Type: string.
Example: afsis.info@africasoils.net.

### scan_mir.600_abs
Description: Absorbance in log10 unit, first wavenumber in the 600-4000 cm-1 range.
Type: numeric.
Example: 1.38812.

### scan_mir.4000_abs
Description: Absorbance in log10 unit, last wavenumber in the 600-4000 cm-1 range.
Type: numeric.
Example: 0.2452604.

## VisNIR scans {#visnir-table}

Visible and Near-Infrared (VisNIR) spectra is provided in reflectance units per wavelength, with values usually ranging between 0 and 1 as fraction percent. The spectral range imported into the OSSL falls between 350 and 2500 nm, with an interval of 2 nm. All datasets are harmonized to this specification.

One can convert reflectance (R) values to absorbance units (A) as `A = log10(1/R)`, or backtransform with `R = 1/(10^A)`. Similarly, wavenumber (WN, in cm<sup>-1</sup>) can be converted to wavelength (WL, in nm) with `WN = 1/(WL*10000000)`, or backtransform with `WL = 1/(WL*10000000)`. The factor 10M is used to convert cm to nm.


### id.layer_uuid_txt
Description: OSSL unique identifier.
Type: string.
Example: bb01d3da0ea0d4d796b3391bb1d174f1.

### id.scan_local_c
Description: Original scan identifier.
Type: string.
Example: 196784MD01.

### scan.visnir.date.begin_iso.8601_yyyy.mm.dd
Description: Begin date of scanning following YYYY-MM-DD format (ISO 8601).
Type: numeric.
Example: 2015-03-05.

### scan.visnir.date.end_iso.8601_yyyy.mm.dd
Description: Begin date of scanning following YYYY-MM-DD format (ISO 8601).
Type: numeric.
Example: 2015-03-05.

### scan.visnir.model.name_utf8_txt
Description: VisNIR instrument manufacturer, model and accessory (if any).
Type: string.
Example: ASD Labspec 2500 with Muglight accessory.

### scan.visnir.model.code_any_txt
Description: VisNIR instrument coding.
Type: string.
Example: ASD_Labspec_2500_MA.

### scan.visnir.method.optics_any_txt
Description: Metadata information related to instrument optics and measurements.
Type: string.
Example: 4.5 W halogen lamp.

### scan.visnir.method.preparation_any_txt
Description: Soil sample preparation before scanning.
Type: string.
Example: Sieved <2 mm.

### scan.visnir.license.title_ascii_txt
Description: Dataset scans license.
Type: string.
Example: CC-BY.

### scan.visnir.license.address_idn_url
Description: Dataset scans license url.
Type: string.
Example: https://www.nrcs.usda.gov/resources/data-and-reports/rapid-carbon-assessment-raca.

### scan.visnir.doi_idf_url
Description: Digital object identifier (DOI) url of the dataset scans.
Type: string.
Example: https://doi.org/10.1007/978-3-319-04084-4_10.

### scan.visnir.contact.name_utf8_txt
Description: Dataset scans contact name.
Type: string.
Example: Scarlett Murphy.

### scan.visnir.contact.email_ietf_txt
Description: Dataset scans contact email.
Type: string.
Example: Scarlett.Murphy@usda.gov.

### scan_visnir.350_ref
Description: Reflectance in fraction unit, first wavelength in the 350-2500 nm range.
Type: numeric.
Example: 0.10403320.

### scan_visnir.2500_ref
Description: Reflectance in fraction unit, last wavelength in the 350-2500 nm range.
Type: numeric.
Example: 0.3622029.
<!-- ## Harmonization rules -->

<!-- The following description includes harmonization/conversion rules recommended in this project. -->
<!-- For each conversion rule, a reference and an example are provided to prevent from  -->
<!-- misusing the rules. The following principle of harmonization are highly recommended: -->

<!-- 1. Document (R code) any harmonization / conversion steps.\ -->
<!-- 2. Where possible provide propagated measure of uncertainty. This can further used  -->
<!-- as weights in the Machine Learning / model building.\ -->
<!-- 3. Any conversion that leads to inducting significant bias (over-/under-estimation  -->
<!-- of values) should we avoided.\ -->
<!-- 4. Add to the produced dataset metadata that part of data has been harmonized and  -->
<!-- specify exact method.\ -->

<!-- Disclaimer: use at own risk. See also our general disclaimer. -->

<!-- ### pH -->

<!-- From `ph.kcl_usda.4c1_index` to `ph.h2o_usda.4c1_index` based on @bohner2008saga: -->

<!-- ```{r} -->
<!-- ph.kcl = 6.5 -->
<!-- ph.h2o = ph.kcl / 0.87 -->
<!-- ph.h2o -->
<!-- ``` -->

<!-- From `ph.cacl2_usda.4c1_index` to `ph.h2o_usda.4c1_index` based on @miller2010comparison: -->

<!-- ```{r} -->
<!-- ph.cacl2 = 6.5 -->
<!-- ph.h2o = (ph.cacl2 + 0.973 ) / 1.08 -->
<!-- ph.h2o -->
<!-- ``` -->


<!-- ### Carbon -->

<!-- From `humus_usda.4h2_wpct` to `oc_usda.4h2_wpct` based on @nelson1983total: -->

<!-- ```{r} -->
<!-- humus = 4 -->
<!-- oc = humus / 1.724 -->
<!-- oc -->
<!-- ``` -->

<!-- From `humus_usda.4h2_wpct` to `oc_usda.4h2_wpct` based on @jensen2018converting: -->

<!-- ```{r} -->
<!-- humus = 4; clay = 10 -->
<!-- oc1 = 0.513 * humus - (0.047 * clay - 0.00025 * clay^2) -->
<!-- oc1 -->
<!-- humus = 4; clay = 20 -->
<!-- oc2 = 0.513 * humus - (0.047 * clay - 0.00025 * clay^2) -->
<!-- oc2 -->
<!-- ``` -->

<!-- ### Phosphorous -->

<!-- ### Potassium -->

<!-- ### Nitrogen -->

<!-- ### Exchangeable cations and CEC -->

<!-- From `k.ext` extracted by Mehlich-3 (cmol/kg) to `ecec.ext_usda.4b1_cmolkg` based on @helling1964contribution: -->

<!-- ```{r} -->
<!-- ph.h2o = 6.5 -->
<!-- k.ext = 2 -->
<!-- ca.ext = 12 -->
<!-- na.ext = 2 -->
<!-- mg.ext = 1 -->
<!-- ecec.ext = ifelse(ph.h2o < 7.5 & ph.h2o>4, (k.ext + ca.ext + na.ext + mg.ext), NA) -->
<!-- ecec.ext -->
<!-- ``` -->

<!-- From `oc_usda.4h2_wpct` to `ecec.ext_usda.4b1_cmolkg` based on @helling1964contribution: -->

<!-- ```{r} -->
<!-- clay.tot = 28 -->
<!-- ph.h2o = 6.5 -->
<!-- oc = 2 -->
<!-- ecec.ext = ((clay.tot*10/100*(30+4.4*ph.h2o))+(oc/100*(-59+51*ph.h2o)))/10 -->
<!-- ecec.ext -->
<!-- ``` -->

<!-- ### Texture fractions -->

<!-- ### Bulk density -->

<!-- ### Soil biological variables -->

<!-- ### Soil contaminants -->

