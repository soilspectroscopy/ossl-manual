---
knit: "bookdown::render_book"
title: "Open Soil Spectral Library"
author: "Woodwell Climate Research Center, University of Florida, OpenGeoHub and contributors"
description: "Open Soil Spectroscopy Library technical documentation. Use these documentation to access OSSL data, fit models, and use the reference models."
url: 'https\://soilspectroscopy.github.io/ossl-manual'
bibliography: ./tex/refs.bib
csl: ./tex/apa.csl  
documentclass: svmono
classoption: graybox,natbib,nospthms
geometry: "paperwidth=18.90cm, paperheight=24.58cm, top=2.1cm, bottom=2.1cm, inner=2cm, outer=2cm"
monofont: "Source Code Pro"
monofontoptions: "Scale=0.7"
biblio-style: spbasic
fig_caption: yes
link-citations: yes
gihub-repo: soilspectroscopy/ossl-manual
twitter-handle: soilspec
cover-image: cover.png
site: bookdown::bookdown_site
---

# About {.unnumbered}

[![Access source code](cover.jpg){.cover width="250"}](https://soilspectroscopy.org/)

[![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.5759693.svg)](https://doi.org/10.5281/zenodo.5759693)

> "Man’s most human characteristic is not his ability to learn, which he shares 
> with many other species, but his ability to teach and store what others have 
> developed and taught him."
> Margaret Mead, Culture and Commitment: The New Relationships Between the Generations in the 1970s

## Soil Spectroscopy for Global Good {.unnumbered}

[**SoilSpec4GG**](https://soilspectroscopy.org/) is a USDA-funded [Food and Agriculture Cyberinformatics
Tools Coordinated Innovation Network NIFA Award #2020-67021-32467](https://nifa.usda.gov/press-release/nifa-invests-over-7-million-big-data-artificial-intelligence-and-other) project. It brings together soil
scientists, spectroscopists, informaticians, data scientists and
software engineers to overcome some of the current bottlenecks
preventing wider and more efficient use of soil spectroscopy. A series
of working groups will be formed to address topics including calibration
transfer, model choice, outreach & demonstration, and use of
spectroscopy to inform global carbon cycle modeling. For more info refer
to: <https://soilspectroscopy.org/>.

<img src="img/soilspec4gg-logo_fc.png" width="60%" />

R tutorials and software developed to implement OSSL is available via: <https://github.com/soilspectroscopy>.

Soil spectroscopy for global good project works with other global initiatives including the **[FAO Global Soil Partnership](https://www.fao.org/global-soil-partnership/glosolan/en/)** and the **[IEEE P4005 Standards and Protocols for Soil Spectroscopy](https://sagroups.ieee.org/4005/)** Working Group.

## What is soil spectroscopy? {.unnumbered}

Soil spectroscopy is the measurement of light absorption when light in the [visible, near infrared or mid infrared (Vis–NIR–MIR) regions of the electromagnetic spectrum](https://en.wikipedia.org/wiki/Electromagnetic_spectrum) is applied to a soil surface. The proportion of the incident radiation reflected by soil is sensed through Vis–NIR–MIR reflectance spectroscopy. These characteristic spectra (see Fig. below) can then be used to estimate numerous soil attributes including: particle size, mineral and organic compounds, and water. 

<div class="figure" style="text-align: center">
<img src="img/Spectroscopy-Schematic.jpeg" alt="Schematic explanation of the soil spectroscopy. For more info see: https://soilspectroscopy.org/." width="100%" />
<p class="caption">(\#fig:soil-pnts)Schematic explanation of the soil spectroscopy. For more info see: https://soilspectroscopy.org/.</p>
</div>

<div class="figure" style="text-align: center">
<img src="img/VNIR_Raw_Spectra.png" alt="Example of spectral signatures for large number of VisNIR scans (KSSL)." width="80%" />
<p class="caption">(\#fig:soil-visnir)Example of spectral signatures for large number of VisNIR scans (KSSL).</p>
</div>

## Open Soil Spectral Library {.unnumbered}

[![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.5759693.svg)](https://doi.org/10.5281/zenodo.5759693)

The **Open Soil Spectral Library** (OSSL) is a suite of datasets, web-services, software, and tutorials. It includes (see also <https://github.com/soilspectroscopy>):

- A soil spectral database shared through several formats (mongoDB, cloud bucket, and API);  
- API with database access and a prediction service available from [https://api.soilspectroscopy.org](https://api.soilspectroscopy.org/__docs__/#/);  
- Front-end solutions: **[OSSL Engine](https://engine.soilspectroscopy.org/)** and **[OSSL Explorer](https://explorer.soilspectroscopy.org/)**;   
<!-- - An R package `ossl` with all functionality used by the API;  -->
- Registry of global and local prediction models (<https://github.com/soilspectroscopy/>);  
- Tutorials included in this book.  

## Importing new datasets to OSSL {.unnumbered}

The OSSL database has been prepared following the OSSL schema which is available at [ossl-imports](https://github.com/soilspectroscopy/ossl-imports).

The github repository [ossl-imports](https://github.com/soilspectroscopy/ossl-imports) has all the importing codes for preparing and integrating new datasets into the OSSL. The folder [ossl-imports/dataset](https://github.com/soilspectroscopy/ossl-imports/tree/main/dataset) contains all the datasets separated by its name/code, with an internal `README.Rmd` file describing in detail the steps necessary for preparing and standardizing the files into the OSSL format.

The original files are placed on an internal server to avoid the storage of big files in the github repository, but some of them can be found on persistent online repositories if they have a public license. Other original datasets that do not have a public license or are shared to this project with some restrictions will no be shared publicly. As we keep the original files in a local repository to run the importing notebooks (each `ossl-imports/dataset/../README.Rmd`), this operation can only be run at our internal server.

New contributors are encouraged to host their files on a public repository and draft the importing step on github through pull requests. The final checks and consolidation, however, will be concluded on the internal server.

The `README.Rmd` files follow a basic structure. Each one has a description of the dataset at the top of the notebook which links to the dataset source and references. An extended description is provided in [this book](https://soilspectroscopy.github.io/ossl-manual/soil-spectroscopy-tools-and-users.html#registered-soil-spectral-libraries).

For preparing the import, the following subsections are defined:

- Basic description.
- Soil site information.
- Soil laboratory (wet chemistry) data
- Mid-infrared (MIR) spectroscopy data (optional).
- Visible-near-infrared (VisNIR) spectroscopy data (optional).
- Quality control.
- References.

Each subsection has its own reading and processing functions, and the outputs can be joined using shared id columns. The output files share the same name and pattern but can be retrieved with different folder names, which are binded together in a final stage. The outputs are named as `ossl_soilsite_<version>.qs`, `ossl_soillab_<version>.qs`, `ossl_mir_<version>.qs`, `ossl_visnir_<version>.qs`. The version number is adjusted for recurring updates.

## Soil properties of interest {.unnumbered}

The contrasting methods used for analytically determining (wet chemistry) a given soil property has been a subject of internal discussion in this project. Some global initiatives have been facing this same issue in their soil databases but there still no clear or full consensus on how to harmonize those different methods. This has been a topic of great discussion and research development at the [Global Soil Partnership’s Global Soil Laboratory Network (GLOSOLAN)](https://www.fao.org/global-soil-partnership/glosolan/en/).

In order to maximize transparency, for now, we have decided to produce two different levels for the OSSL database. `Level 0` takes into account the original methods employed in each dataset but tries to initially fit them to two reference lists: [KSSL Guidance – Laboratory Methods and Manuals](https://www.nrcs.usda.gov/resources/guides-and-instructions/kssl-guidance) and ISO standards. A copy of the KSSL procedures and coding scheme is archived in [ossl-imports](https://github.com/soilspectroscopy/ossl-imports/blob/main/out/kssl_procedures.csv).

If a reference method does not fall in any previous method, then we create a new variable sharing at least a common property and unit. A final harmonization takes place in the OSSL `Level 1`, where those common properties sharing different methods are converted to a target method using some publicly available transformation rule, or in the worst scenario, they are naively binded or kept separated to produce its specific model. All the implementations are documented in the [ossl-import/ossl_level0_to_level1_soillab_harmonization.csv](https://github.com/soilspectroscopy/ossl-imports/blob/main/out/ossl_level0_to_level1_soillab_harmonization.csv) repository.

In addition, [GLOSOLAN's Standard Operating Procedures (SOPs)](http://www.fao.org/global-soil-partnership/glosolan/soil-analysis) list four groups of soil variables of interest to international soil spectroscopy projects:

Soil chemical variables:

- pH,  
- Carbon,  
- Phosphorous,  
- Potassium,  
- Nitrogen,  
- Exchangeable cations and CEC,  
- Extractable microelements,  
- Trace and major element analyses,  
- Gypsum,  
- Electrical conductivity and total soluble salt content,  
- Soluble sulfate and chloride analysis,  
- Special analysis for peats, mineral and organic soils, agriculture and forest,  

Soil physical variables:

- Bulk density,  
- Coarse fragments,  
- Particle-size distribution,  
- Water retention curve,  
- Porosity,  
- Hydraulic conductivity function,  
- Aggregate stability,  
- Moisture content,  

Soil biological variables:

- Microbial biomass,  
- Soil Respiration,  
- Enzyme activity,  
- Microbial identification,  

Soil contaminants:

- Heavy metal elements: As, Hg, Cu, Cd, Pb and similar,  
- Other soil pollutants,  

## Contributing data {.unnumbered}

We encourage public and private entities to help this project and share SSL data. The following four modes of data sharing are especially encouraged:

1. Open your data by releasing it under Creative Commons ([CC-BY](https://creativecommons.org/licenses/by/4.0/), [CC-BY-SA](https://creativecommons.org/licenses/by-sa/4.0/))  
or Open Data Commons Open Database License ([ODbL](https://opendatacommons.org/licenses/odbl/)). 
This data can then directly imported into the OSSL.  
2. Donate a small part (e.g. 5%) of your data (release under [CC-BY](https://creativecommons.org/licenses/by/4.0/), [CC-BY-SA](https://creativecommons.org/licenses/by-sa/4.0/) and/or [ODbL](https://opendatacommons.org/licenses/odbl/)). 
This data can then directly imported into the OSSL.  
2. Allow SoilSpectroscopy.org project direct access to your data so that we can run data mining 
and then release ONLY results of data mining under some Open Data license.  
3. Use OSSL data to produce new derivative products, then share them through own 
infrastructures OR contact us for providing hosting support.  

We can sign professional **Data Sharing Agreements** with data producers 
that specify in detail how will the data be used. Our primary interest is in enabling research, 
sharing and use of models (calibration and prediction) and collaboration of groups 
across borders.

We take especial care that your data is secured, encrypted where necessary, 
and kept safely, closely following our [privacy policy and terms of use](https://www.woodwellclimate.org/privacy-policy/).

## Contributing documentation {.unnumbered}

Please feel free to contribute to this technical documentation. Check the [GitHub repository](https://github.com/soilspectroscopy/ossl-manual) for more detailed instructions.

Information outdated or missing? Please [open an issue](https://github.com/soilspectroscopy/ossl-manual/issues) or best do a
correction in the text and then make a [pull request](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request).

## Contributors {.unnumbered}

If you've contribute, add also your name and Twitter, ORCID or blog link below:

[Jonathan Sanderman](https://twitter.com/sandersoil),
[Tomislav Hengl](https://twitter.com/tom_hengl),
[Katherine Todd-Brown](https://www.essie.ufl.edu/people/name/kathe-todd-brown/),
[Leandro L. Parente](https://www.linkedin.com/in/leal-parente/),
[Wanderson de Sousa Mendes](https://www.linkedin.com/in/wanderson-de-sousa-mendes-75a16195/),
[Dellena Bloom](https://www.linkedin.com/in/dellena-bloom-541817149/),
[José Lucas Safanelli](https://www.linkedin.com/in/joselucassafanelli/).   

## Disclaimer {.unnumbered}

Whilst utmost care has been taken by the Soil Spectroscopy project and data authors while
collecting and compiling the data, the data is provided _"as is"_. [Woodwell Climate Research Center](https://www.woodwellclimate.org/), [University of Florida](https://faculty.eng.ufl.edu/ktoddbrown/), [OpenGeoHub foundation](https://opengeohub.org/about) and its 
suppliers and licensors hereby disclaim all warranties of any kind, express or implied, 
including, without limitation, the warranties of merchantability, fitness for a particular 
purpose and non-infringement. Neither [Woodwell Climate Research Center](https://www.woodwellclimate.org/), [University of Florida](https://faculty.eng.ufl.edu/ktoddbrown/), [OpenGeoHub foundation](https://opengeohub.org/about) nor its suppliers and licensors, 
makes any warranty that the Website will be error free or that access thereto will be 
continuous or uninterrupted. You understand that you download from, or otherwise obtain 
content or services through, the Website at your own discretion and risk.

In no event shall the data authors, the Soil Spectroscopy project, or relevant funding
agencies be liable for any actual, incidental or consequential damages arising from use of the data.
By using the Soil Spectroscopy project data, the user expressly acknowledges that the Data
may contain some nonconformities, defects, or errors. No warranty is given that the data will meet
the user's needs or expectations or that all nonconformities, defects, or errors can or will be
corrected. The user should always verify actual data; therefore the user bears all responsibility in
determining whether the data is fit for the user’s intended use.

This document is **under construction**. If you notice an error or outdated information, 
please submit a correction/pull request or **[open an issue](https://github.com/soilspectroscopy/ossl-manual/issues)**.  

This is a community project. No profits are being made from building and serving 
Open Spectral Library. If you would like to become a sponsor of the project, please 
contact us via: <https://soilspectroscopy.org/contact/>.  

## Licence {.unnumbered}

This website/book and attached software is free to use, and is licensed under [the MIT License](https://en.wikipedia.org/wiki/MIT_License). The OSSL training data and models, 
if not otherwise indicated, is available either under the [Creative Commons Attribution 4.0 International CC-BY](https://creativecommons.org/licenses/by/4.0/legalcode) 
and/or [CC-BY-SA](https://creativecommons.org/licenses/by-sa/4.0/legalcode) license / [Open Data Commons Open Database License (ODbL) v1.0](https://opendatacommons.org/licenses/odbl/1-0/).

## Suggested literature {.unnumbered}

Some other connected publications and initiatives describing collation, 
import and use of soil spectroscopy data:

- Angelopoulou, T., Balafoutis, A., Zalidis, G., & Bochtis, D. (2020). [From laboratory to proximal sensing spectroscopy for soil organic carbon estimation—a review](https://doi.org/10.3390/su12020443). Sustainability, 12(2), 443. <https://doi.org/10.3390/su12020443>  
- Ayres, E. (2019). [Quantitative Guidelines for Establishing and Operating Soil Archives](https://doi.org/10.2136/sssaj2019.02.0050). Soil Science Society of America Journal, 83(4), 973-981. <https://doi.org/10.2136/sssaj2019.02.0050>  
- Benedetti, F. and van Egmond, F. (2021). [Global Soil Spectroscopy Assessment](https://doi.org/10.4060/cb6265en). Spectral soil data – Needs and capacities. Rome, FAO. <https://doi.org/10.4060/cb6265en>  
- Dudek, M., Kabała, C., Łabaz, B., Mituła, P., Bednik, M., & Medyńska-Juraszek, A. (2021). [Mid-Infrared Spectroscopy Supports Identification of the Origin of Organic Matter in Soils](https://doi.org/10.3390/land10020215). Land, 10(2), 215. <https://doi.org/10.3390/land10020215>  
- [GLOSOLAN's Standard Operating Procedures (SOPs)](http://www.fao.org/global-soil-partnership/glosolan/soil-analysis/standard-operating-procedures/en/#c763834);  
- Nocita, M., Stevens, A., van Wesemael, B., Aitkenhead, M., Bachmann, M., Barthès, B., ... & Wetterlind, J. (2015). [Soil spectroscopy: An alternative to wet chemistry for soil monitoring](https://doi.org/10.1016/bs.agron.2015.02.002). Advances in agronomy, 132, 139-159. <https://doi.org/10.1016/bs.agron.2015.02.002>  
- Sanderman, J., Savage, K., Dangal, S. R., Duran, G., Rivard, C., Cavigelli, M. A., ... & Stewart, C. (2021). [Can Agricultural Management Induced Changes in Soil Organic Carbon Be Detected Using Mid-Infrared Spectroscopy?](https://doi.org/10.3390/rs13122265). Remote Sensing, 13(12), 2265. <https://doi.org/10.3390/rs13122265>  
- Sanderman, J., Savage, K., & Dangal, S. R. (2020). [Mid-infrared
spectroscopy for prediction of soil health indicators in the United
States](https://doi.org/10.1002/saj2.20009). Soil Science Society of America Journal, 84(1), 251–261.
<https://doi.org/10.1002/saj2.20009>  
- Wijewardane, N. K., Ge, Y., Wills, S., & Libohova, Z. (2018). [Predicting
physical and chemical properties of US soils with a mid-infrared
reflectance spectral library](https://doi.org/10.2136/sssaj2017.10.0361). Soil Science Society of America Journal,
82(3), 722–731. <https://doi.org/10.2136/sssaj2017.10.0361>  
- Wadoux, A.M.J.-C., Malone, B., McBratney, A.B., Fajardo, M., Minasny, B., (2021). [Soil Spectral Inference with R: Analysing Digital Soil Spectra Using the R Programming Environment](https://books.google.nl/books?id=4kQgEAAAQBAJ). Progress in Soil Science, Springer Nature, ISBN: 9783030648961, 274 pp.  

## Acknowledgments {.unnumbered}

Open Soil Spectral Library was possible due to the kind contributions by public and private 
organizations. Listed based on the date of import:

- **[USDA-NRCS Kellogg Soil Survey Laboratory](https://ncsslabdatamart.sc.egov.usda.gov/datause.aspx)** mid-infrared (MIR) spectral library [@wijewardane2018predicting;@sanderman2020mid] was used as the basis for this data set and corresponding services; we are especially grateful to **Rich Ferguson & Scarlett Murphy (NRCS USDA)** for their help with importing and using the KSSL Soil Spectral Library;  
- **[ICRAF-ISRIC Soil VNIR Spectral Library](https://doi.org/10.34725/DVN/MFHA9C)** [@garrity2004globally; @aitkenhead2018exploring] 785 soil profiles (4,438 samples) selected from the Soil Information System (ISIS) of the International Soil Reference and Information Centre (ISRIC) <https://doi.org/10.34725/DVN/MFHA9C>;  
- **[AfSIS-I Soil Spectral Library](https://doi.org/10.34725/DVN/QXCWP1)** Mid-Infrared Spectra (MIRS) from ICRAF Soil and Plant Spectroscopy Laboratory Africa Soil Information Service (AfSIS) Phase I 2009-2013 [@Vagen_2020], a collaborative project funded by the Bill and Melinda Gates Foundation (BMGF). Partners included: CIAT-TSBF, ISRIC, CIESIN, The Earth Institute at Columbia University and World Agroforestry (ICRAF) <https://doi.org/10.34725/DVN/QXCWP1>;
  **[AfSIS-II Soil Spectral Library](https://doi.org/10.34725/DVN/QXCWP1)** with Mid-Infrared Spectra (MIRS) covering the national Soil Information Systems: TanSIS (Tanzania), NiSIS (Nigeria) and GhanSIS (Ghana) available from <https://doi.org/10.34725/DVN/XUDGJY>, <https://doi.org/10.34725/DVN/WLAKR2> and <https://doi.org/10.34725/DVN/SPRSFN> and hosted by the ICRAF Soil and Plant Spectroscopy Laboratory;
- **[LUCAS topsoil (VisNIR) Soil Spectral Library](http://esdac.jrc.ec.europa.eu/)** [@orgiazzi2018lucas] was made available by the European Commission through the European Soil Data Centre managed by the Joint Research Centre (JRC), <http://esdac.jrc.ec.europa.eu/>; we have degraded location accuracy of points so that exact locations are about 1-km off;  
- **[The Central African Soil Spectral Library](https://github.com/laura-summerauer/ssl-central-africa)** described in detail in @Summerauer2021 contains limited number of samples representing Central Africa <https://doi.org/10.5281/zenodo.4320395>;  
<!-- - **The National Ecological Observatory Network (NEON) Soil Spectral** is based on the NEON soil data [@ayres2019quantitative], which were scanned by the Woodwell Climate Research and USDA-NRCS Kellogg Soil Survey Laboratory; the [(NEON) Megapit Soil Archive](https://www.neonscience.org/samples/soil-archive) is a program sponsored by the National Science Foundation and operated under cooperative agreement by Battelle;   -->

We are grateful to **[Wanderson de Sousa Mendes (Leibniz Centre for Agricultural Landscape Research (ZALF))](https://www.linkedin.com/in/wanderson-de-sousa-mendes-75a16195/)** for 
help with initial screening of the data for the development of the R code for processing soil spectroscopy data.

For more advanced uses of the soil spectral libraries **we advise to contact the original data producers** 
especially to get help with using, extending and improving the original SSL data.

We are also grateful to **[USDA National Institute of Food and Agriculture #2020-67021-32467](https://nifa.usda.gov/press-release/nifa-invests-over-7-million-big-data-artificial-intelligence-and-other)** for providing funding for this project.
