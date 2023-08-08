# Web applications and API

::: {.rmdnote}
You are reading the work-in-progress of the SoilSpec4GG manual. This chapter is currently draft version, a peer-review publication is pending.
:::

## OSSL Explorer

The OSSL Explorer is a web platform where the user can explore the OSSL database. Use it to subset and explore data based on geographical filters (Geography tab) or based on the range of soil properties (Soil properties tab). Once applied the selection, you can download the data by clicking on the bottom right option 'Download now'. If you want to restart the filters, click 'Clear selection'. For accessing the full database by other means (programmatically) or just download it as `csv` or `qs` format, please check the instructions on **[OSSL database access](https://soilspectroscopy.github.io/ossl-manual/ossl-database-access.html)**.

<div class="figure" style="text-align: center">
<img src="img/explorer1.png" alt="OSSL Explorer initial page that allows filtering OSSL samples based on geographical distribution." width="100%" />
<p class="caption">(\#fig:explorer1)OSSL Explorer initial page that allows filtering OSSL samples based on geographical distribution.</p>
</div>

<div class="figure" style="text-align: center">
<img src="img/explorer2.png" alt="OSSL Explorer page that allows filtering OSSL samples based on range of soil properties." width="100%" />
<p class="caption">(\#fig:explorer2)OSSL Explorer page that allows filtering OSSL samples based on range of soil properties.</p>
</div>

## OSSL Engine

The OSSL Engine is a web platform where the user can upload spectra from the **VisNIR (400-2500 nm), NIR (1350-2550 nm), or MIR (600-4000 cm<sup>-1</sup>) ranges** and get predictions back with uncertainty estimation and representativeness flag. The modeling framework, cross-validation performance metrics, and furhter information can be checked over **[OSSL prediction models](https://soilspectroscopy.github.io/ossl-manual/ossl-prediction-models.html)**.

Please, check the **[example datasets](https://github.com/soilspectroscopy/ossl-manual/tree/main/sample-data)** for formatting your spectra to the minimum required level. You can provide either `csv` files or directly `asd` or opus (`.0`) for VisNIR and MIR scans, respectively.

>> We recommend using the OSSL model type when getting predictions. KSSL is recommended when the spectra to be predicted have the same instrument manufacturer/model as the KSSL library and are represented by the range of soil properties of interest. Otherwise, use the OSSL library.

<div class="figure" style="text-align: center">
<img src="img/engine1.png" alt="OSSL Engine initial page for uploading data, confirming spectra, and selecting model type." width="100%" />
<p class="caption">(\#fig:engine1)OSSL Engine initial page for uploading data, confirming spectra, and selecting model type.</p>
</div>

<div class="figure" style="text-align: center">
<img src="img/engine2.png" alt="OSSL Engine page with the outputs from model predictions, including response, uncertainty interval, and trustworthiness flag." width="100%" />
<p class="caption">(\#fig:engine2)OSSL Engine page with the outputs from model predictions, including response, uncertainty interval, and trustworthiness flag.</p>
</div>

## OSSL API

[OSSL API](https://api.soilspectroscopy.org/__docs__/#/) (Application Programming Interface) is also available and can be used to construct requests to fetch data, models, and generate predictions. The outputs of predictions can be obtained as [JSON](https://www.json.org/json-en.html) or CSV files, making the system fully interoperable. The OSSL API is at the moment based on using the [plumber package](https://www.rplumber.io/) and is **provided for testing purposes only**. Users can make predictions with pre-trained models for 20 spectra per request, but these limits will be gradually extended.

<div class="figure" style="text-align: center">
<img src="img/preview_ossl_api_swagger.png" alt="OSSL API is available for testing." width="100%" />
<p class="caption">(\#fig:ossl-api)OSSL API is available for testing.</p>
</div>

