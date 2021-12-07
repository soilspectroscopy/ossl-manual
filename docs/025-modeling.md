---
editor_options: 
  markdown: 
    wrap: 72
---

# Reference soil spectroscopy models

The following sections describe steps used to produce OSSL models, which 
are used in the OSSL calibration service and API. For more in-depth insight of 
the modeling steps please refer to the [ossl-models](https://github.com/soilspectroscopy/ossl-models) repository.

## OSSL global soil spectroscopy callibrarion models

We have fitted a number of calibration models using OSSL MIR and VisNIR spectra 
and combination of additional covariates, and which are now publicly available 
for use under the CC-BY license. For modeling we use the Ensemble Machine Learning 
framework as implemented in the R [mlr](https://mlr.mlr-org.com/) programming environment 
with the following parameters:

1. Regression on first 60 Principal Component Analysis PC's of the raw spectra;  
2. Four base learners: Random Forest, Gradient Boosting, Cubist and Lasso and Elastic-Net Regularized GLM;  
3. Ensemble Machine Learning by [stacking / meta-learner](https://mlr.mlr-org.com/reference/makeStackedLearner.html) through 5-fold Cross-Validation;  
4. Blocking using 100×100-km spatial grid to avoid possible overfitting;  
5. [Feature selection](https://mlr.mlr-org.com/articles/tutorial/feature_selection.html) and model-parameter fine-tuning using random and sequential backward search;  

For more details on how were the models fitted refer to: <https://github.com/soilspectroscopy/ossl-models>.

For standard global soil spectral calibration models we use various calibration frameworks including:

1. Using only MIR spectra for calibration.  
2. Using only VisNIR spectra for calibration.  
3. Using combination of MIR and VisNIR spectra.  
4. Using combination of MIR and VisNIR spectra + geographic covariates.  

The methods 1 & 2 are standard methods described in literature [@malone2021soil]. The methods 
3 & 4 are referred to as the _"MIR-VisNIR fusion"_ approach [@vohland2022quantification].
The method 4 is the _"field-specific calibration approach"_; we refer to it here 
as the _"bundle approach"_ as we basically use all information available 
to help produce best predictions of targeted soil properties.

Users can choose to opt for one of the multiple calibration models, which also 
depends on the type of data (VisNIR, MIR, coordinates and depths known yes/no) used of course.
The online callibration service (<https://engine.soilspectroscopy.org>) and the API 
can be used for predicting values of soil properties for smaller datasets (<1000 rows). 

Soil spectral scans obtained by different spectroscopic instruments often cannot be 
modeled or analyzed together i.e. they require some kind of calibration [@lei2022achieving] 
before one can fit cross-instrument / cross-dataset calibration models.
In the OSSL library we thus use also instrument / dataset code as the indicator variable. 
The most complex models currently in the OSSL are, thus, one with which users need to define both:

1. Input MIR spectra,
2. Input VisNIR spectra (same samples),
3. Geographical location and soil depth,
4. Instrument code / dataset code;


## Using default OSSL models to predict soil properties

OSSL model registry (RDS) S3 file services currently includes large number of 
prediction models fitted for a list of soil properties. The complete list is available in the file **[OSSL_models_meta.csv](https://github.com/soilspectroscopy/ossl-models)**.



### Predicting soil properties using MIR spectra

For example, to predict [soil organic carbon weight percent](https://soilspectroscopy.github.io/ossl-manual/database.html#oc_usda.calc_wpct) (`oc_usda.calc_wpct`) using MIR spectra, we need to load 
two models (1) principal component model `mpca_mir_kssl_v1.rds`, 
(2) mlr model for predicting `oc_usda.calc_wpct`:


```r
source('./R/ossl_functions.R')
rep = "http://s3.us-east-1.wasabisys.com/soilspectroscopy/ossl_models/"
pcm1 = url(paste0(rep, "pca.ossl/mpca_mir_kssl_v1.rds"), "rb")
eml1 = url(paste0(rep, "log..oc_usda.calc_wpct/mir_mlr..eml_kssl_na_v1.rds"), "rb")
ossl.pca.mir = readRDS(pcm1)
ossl.model = readRDS(eml1)
```

Note that the models (RDS files) can be between 10 to 200 MB in size, depending on complexity of models 
and the size of the training data used. 

The Principal Component Analysis is described in the [OSSL models repository](https://github.com/soilspectroscopy/ossl-models/). 
It is a standard way of compressing 1000+ spectral bands before predictive modeling [@chang2001near].
We use the first 60 PCA components for further modeling, which is an arbitrary decisions.

We can look at the summary of model by typing:


```r
summary(ossl.model$learner.model$super.model$learner.model)
```

```
Residuals:
    Min      1Q  Median      3Q     Max 
-3.1506 -0.0525  0.0181  0.0661  3.2965 

Coefficients:
               Estimate Std. Error t value Pr(>|t|)    
(Intercept)   -0.038545   0.001042  -36.98   <2e-16 ***
regr.ranger    0.235387   0.004115   57.20   <2e-16 ***
regr.xgboost  -0.046506   0.003291  -14.13   <2e-16 ***
regr.cvglmnet  0.470197   0.004078  115.30   <2e-16 ***
regr.cubist    0.362526   0.003946   91.88   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.1539 on 57400 degrees of freedom
Multiple R-squared:  0.9821,	Adjusted R-squared:  0.9821 
F-statistic: 7.857e+05 on 4 and 57400 DF,  p-value: < 2.2e-16
```

This shows that the model is an ensemble Machine Learning model based on stacking of 
four individual models: `regr.ranger` (Random Forest) [@wright2017ranger], `regr.xgboost` (Gradient Boosting) [@chen2015xgboost], 
`regr.cvglmnet` (Lasso and Elastic-Net Regularized GLM) [@friedman2010] and `regr.cubist` (Cubist) [@kuhn2012cubist]. The RMSE 
of the model is 0.1539 (R-square = 0.982), based on 5-fold Cross Validation with spatial blocking (global grid with 100 km blocks). 
Model is based on 57,400 training points.

We can take a look at the accuracy plot for this model:

<div class="figure">
<img src="http://s3.us-east-1.wasabisys.com/soilspectroscopy/ossl_models/log..oc_usda.calc_wpct/ap.mir_mlr..eml_kssl_na_v1.rds.png" alt="Accuracy plot for `log..oc_usda.calc_wpct/mir_mlr..eml_kssl_na_v1.rds`." width="70%" />
<p class="caption">(\#fig:ac-soc1)Accuracy plot for `log..oc_usda.calc_wpct/mir_mlr..eml_kssl_na_v1.rds`.</p>
</div>

Next, we load the sample MIR data that we can use to predict soil organic carbon:


```r
mir.raw = read.csv("./sample-data/sample_mir_data.csv")[,-1]
```

This is a simple table with raw MIR spectral data (absorbances) prepared as a table. 
The column names contain the wavelengths / MIR channels:


```r
dim(mir.raw)
## 20  1765
str(mir.raw[,1:10])
```

```
'data.frame':	20 obs. of  10 variables:
 $ X4001.656: num  0.411 0.357 0.296 0.152 0.238 ...
 $ X3999.728: num  0.411 0.357 0.297 0.152 0.239 ...
 $ X3997.799: num  0.411 0.357 0.297 0.153 0.239 ...
 $ X3995.871: num  0.411 0.357 0.298 0.153 0.24 ...
 $ X3993.942: num  0.411 0.357 0.298 0.153 0.24 ...
 $ X3992.014: num  0.411 0.357 0.299 0.154 0.241 ...
 $ X3990.085: num  0.411 0.358 0.299 0.154 0.242 ...
 $ X3988.156: num  0.412 0.358 0.299 0.154 0.242 ...
 $ X3986.228: num  0.412 0.358 0.3 0.154 0.243 ...
 $ X3984.3  : num  0.411 0.358 0.3 0.155 0.243 ...
```

We can generate predictions by using:


```r
pred.oc = predict.ossl(t.var="log..oc_usda.calc_wpct", mir.raw=mir.raw, 
                       ossl.model=ossl.model, ylim=c(0,100),
                       ossl.pca.mir=ossl.pca.mir)
```

where `ylim=c(0,100)` specifies that the prediction values need to be in the range 0 to 100 (values out of these range will be replaced with either 0 or 100).
The output of this model consists of four parts:

```
List of 4
 $ pred :'data.frame':	20 obs. of  5 variables:
 $ x    :'data.frame':	20 obs. of  68 variables:
 $ model:'data.frame':	57405 obs. of  5 variables:
 $ cf   : num 0.901
```

1. Predictions with back-transformed value and lower and upper prediction intervals (1 std.);
2. Data frame with all covariate layers needed to generate predictions;
3. Summary meta-learner with predicted and observed values;
4. Ratio between variance in predictions produced using base learners and MSE;

The predictions are in the format:


```r
str(pred.oc$pred)
```

```
'data.frame':	20 obs. of  5 variables:
 $ pred.mean : num  -0.0278 0.0463 0.2844 0.7926 -0.0312 ...
 $ pred.error: num  0.131 0.199 0.111 0.186 0.211 ...
 $ tpred.mean: num  0 0.0474 0.3289 1.209 0 ...
 $ lower.1std: num  NA NA 0.189 0.834 NA ...
 $ upper.1std: num  0.109 0.278 0.485 1.66 0.197 ...
 ```

which means that the predicted `oc_usda.calc_wpct` for first row is 0 etc. The 
`lower.1std` and `upper.1std` indicate standard prediction interval based on the 
prediction error derived in the log-space. For higher values of `oc_usda.calc_wpct` 
prediction interval gets thus proportionally higher for larger absolute values e.g. for row 14 it is between 27% and 34%:

```
#pred.oc$pred[14,]
   pred.mean pred.error tpred.mean lower.1std upper.1std
14  3.441673  0.1139194   30.23918   26.87566   34.00856
```

### Predicting soil properties using MIR spectra and geographical covariates

Next, we can also predict values at new location using  calibration model that is 
field-specific i.e. we use MIR spectra in combination with geographic covariates. 
To predict with such data we also need to load geographical locations for the same 
MIR scans:


```r
new.soil = read.csv("./sample-data/sample_soilsite_data.csv")
lon = new.soil$longitude.std.decimal.degrees
lat = new.soil$latitude.std.decimal.degrees
hzn_depth = new.soil$lay_depth_to_top + (new.soil$lay_depth_to_bottom - new.soil$lay_depth_to_top)/2
```

This now comes with three additional columns `lon` and `lat` and soil depth `hzn_depth`, which is 
the middle of the top and bottom depth of the soil horizon. To predict with then specify also the additional 
arguments in the function:


```r
eml2 = url(paste0(rep, "log..oc_usda.calc_wpct/mir_mlr..eml_kssl_ll_v1.rds"), "rb")
ossl.model = readRDS(eml2) 
pred.oc2 = predict.ossl(t.var="log..oc_usda.calc_wpct", mir.raw=mir.raw, ossl.model=ossl.model, ylim=c(0,100),
             ossl.pca.mir=ossl.pca.mir, geo.type="ll", lon=lon, lat=lat, hzn_depth=hzn_depth, cog.dir="/data/WORLDCLIM/")
```

This type of prediction is somewhat more complex as the function `predict.ossl` needs also to overlay 
points (`lon` and `lat`) vs some 62 GeoTIFFs (containing [WorldClim2.1](https://www.worldclim.org/data/worldclim21.html) layers and [MODIS LST](https://doi.org/10.5281/zenodo.1420114) layers). In this case the layers are located on a local machine, which significantly speeds up predictions function. 

We can look at the variable importance table to try to understand how much the 
additional geographical covariate layers help with producing predictions:


```r
xl <- data.frame(importance = ossl.model$learner.model$base.models[[1]]$learner.model$variable.importance)
xl$relative_importance = 100*xl$importance/sum(xl$importance)
xl = xl[order(xl$importance, decreasing = TRUE),]
xl[1:20,]
```

```
                                                      importance relative_importance
mir.PC3                                               5521.13516          44.4468400
mir.PC8                                               1787.82570          14.3925480
mir.PC1                                               1329.03090          10.6991085
hzn_depth                                             1144.91684           9.2169335
mir.PC14                                               236.53609           1.9041884
mir.PC4                                                188.32570           1.5160799
mir.PC2                                                127.37407           1.0254005
mir.PC10                                               118.35989           0.9528336
mir.PC18                                                98.84466           0.7957300
clm_lst_mod11a2.aug.day_m_1km_s0..0cm_2000..2017_v1.0   89.33596           0.7191820
mir.PC7                                                 63.62915           0.5122342
mir.PC17                                                56.04595           0.4511872
mir.PC6                                                 55.01997           0.4429277
mir.PC15                                                54.79086           0.4410833
mir.PC24                                                54.56629           0.4392755
mir.PC11                                                52.60740           0.4235058
clm_lst_mod11a2.feb.day_m_1km_s0..0cm_2000..2017_v1.0   52.41105           0.4219251
mir.PC12                                                41.14582           0.3312366
mir.PC16                                                38.54017           0.3102603
mir.PC9                                                 36.17293           0.2912032
```

here `hzn_depth` comes as an important covariate and so is `lst_mod11a2.aug.day` 
(MOD11A long-term meand daily temperature for August). The original MIR PCA components, however, 
dominate the prediction model.

The global layers (global land mask at 1-km spatial resolution) are listed at <https://github.com/soilspectroscopy/ossl-models> and are available as a Cloud-service / Cloud-Optimized GeoTIFFs. The process of spatial overlay for new prediction locations, however, can significantly increase 
prediction time, so something to be aware of.

### Predicting soil properties using VisNIR spectra

We can also load VisNIR spectra (reflectances) and predict values using the same function:


```r
visnir.raw = read.csv("./sample-data/sample_visnir_data.csv")[,-c(1:2)]
str(visnir.raw[,1:5])
```

```
'data.frame':	20 obs. of  5 variables:
 $ X350: num  0.0855 0.0677 0.2319 0.3179 0.25 ...
 $ X351: num  0.0839 0.0666 0.2305 0.3195 0.2504 ...
 $ X352: num  0.0816 0.0647 0.2277 0.3184 0.2508 ...
 $ X353: num  0.0811 0.0658 0.2261 0.3134 0.2489 ...
 $ X354: num  0.082 0.0674 0.2258 0.3124 0.2464 ...
 ```

We load another PCA model that we prepared using global VisNIR data and the 
mlr-model that was fitted using VisNIR data:
 

```r
pmc3 = url(paste0(rep, "pca.ossl/mpca_visnir_kssl_v1.rds"), "rb")
eml3 = url(paste0(rep, "log..oc_usda.calc_wpct/visnir_mlr..eml_ossl_na_v1.rds"), "rb")
ossl.pca.visnir = readRDS(pmc3)
ossl.model = readRDS(eml3)
pred.oc3 = predict.ossl(t.var="log..oc_usda.calc_wpct", visnir.raw=visnir.raw, ossl.model=ossl.model,
                        ylim=c(0,100), spc.type = "visnir", ossl.pca.visnir = ossl.pca.visnir)
```

This models is similar to MIR model, but the accuracy plot indicates that the accuracy 
might be significantly lower:

<div class="figure">
<img src="http://s3.us-east-1.wasabisys.com/soilspectroscopy/ossl_models/log..oc_usda.calc_wpct/ap.visnir_mlr..eml_ossl_na_v1.rds.png" alt="Accuracy plot for `log..oc_usda.calc_wpct/visnir_mlr..eml_ossl_na_v1.rds`." width="70%" />
<p class="caption">(\#fig:ac-soc2)Accuracy plot for `log..oc_usda.calc_wpct/visnir_mlr..eml_ossl_na_v1.rds`.</p>
</div>

### Importing soil spectral scans using raw data formats

The examples shown above demonstrate prediction results based on using sample 
MIR and VisNIR data (csv files). If you only have raw spectral scan data such as 
[ASD](http://support.asdi.com/Document/Viewer.aspx?id=95) (PAN Analytics Inc.) and/or 
[OPUS files](https://www.bruker.com/en/products-and-solutions/infrared-and-raman/opus-spectroscopy-software.html) (Bruker Inc.), 
you can use various R packages to read files and prepare them for prediction required by OSSL.

Consider for example a sample OPUS file from the [AfSIS-1 project](https://registry.opendata.aws/afsis/), 
which is an original file from the Bruker_Alpha_ZnSe instrument. We can read this file 
thanks to the simplerspec package by using:


```r
mir.x = simplerspec::read_opus_bin_univ('sample-data/icr056141.0')
```

```
## Extracted spectra data from file: <icr056141.0>
```

```r
names(mir.x)
```

```
##  [1] "metadata"          "spc"               "spc_nocomp"       
##  [4] "sc_sm"             "sc_rf"             "ig_sm"            
##  [7] "ig_rf"             "wavenumbers"       "wavenumbers_sc_sm"
## [10] "wavenumbers_sc_rf"
```

which gives a list of object including `spc` which are the spectral bands:


```r
dim(mir.x[["spc"]])
```

```
## [1]    1 1715
```

we can plot the MIR absorbance curve for this scan by using:


```r
x = as.numeric(names(mir.x[["spc"]]))
matplot(y=as.vector(t(mir.x[["spc"]])), x=x,
        ylim = c(0,3),
        type = 'l', 
        xlab = "Wavelength", 
        ylab = "Absorbance"
        )
```

<div class="figure">
<img src="025-modeling_files/figure-html/plot-opus-1.png" alt="Spectral absorbances plot using MIR data." width="90%" />
<p class="caption">(\#fig:plot-opus)Spectral absorbances plot using MIR data.</p>
</div>

This dataset is hence ready to generate predictions using global OSSL models. We can, 
for example generate prediction of soil pH using the following model:

<div class="figure">
<img src="http://s3.us-east-1.wasabisys.com/soilspectroscopy/ossl_models/ph.h2o_usda.4c1_index/ap.mir_mlr..eml_ossl_ll_v1.rds.png" alt="Accuracy plot for `ph.h2o_usda.4c1_index/mir_mlr..eml_ossl_ll_v1.rds`." width="70%" />
<p class="caption">(\#fig:ac-ph1)Accuracy plot for `ph.h2o_usda.4c1_index/mir_mlr..eml_ossl_ll_v1.rds`.</p>
</div>

in this case we need to add also lon-lat coordinates and specify the soil depth:


```r
pcm3 = url(paste0(rep, "pca.ossl/mpca_mir_ossl_v1.rds"), "rb")
eml3 = url(paste0(rep, "ph.h2o_usda.4c1_index/mir_mlr..eml_ossl_ll_v1.rds"), "rb")
ossl.pca.mir = readRDS(pcm3)
ossl.model = readRDS(eml3)
pred.ph1 = predict.ossl(t.var="ph.h2o_usda.4c1_index", mir.raw=mir.x[["spc"]], ossl.model=ossl.model, 
             ossl.pca.mir=ossl.pca.mir, geo.type="ll", lon=28.50299833, lat=-13.10194667, hzn_depth=10, 
             cog.dir="/data/WORLDCLIM/")
```

which gives us predictions of `ph.h2o_usda.4c1_index`:


```r
pred.ph1$pred
```

```
  pred.mean pred.error lower.1std upper.1std
1   5.21567   1.221916   3.993754   6.437586
```

Likewise, we can also read the ASD files to generate predictions using VisNIR spectra.
Consider for example the sample data from the KSSL VisNIR repository:


```r
asd.raw = as.data.frame(asdreader::get_spectra("sample-data/101453MD01.asd"))
dim(asd.raw)
```

```
## [1]    1 2151
```


```r
x = as.numeric(names(asd.raw))
matplot(y=as.vector(t(asd.raw)), x=x,
        ylim = c(0,0.7),
        type = 'l', 
        xlab = "Wavelength", 
        ylab = "Reflectance"
        )
```

<div class="figure">
<img src="025-modeling_files/figure-html/plot-ads-1.png" alt="Spectral reflectance plot using VisNIR data." width="90%" />
<p class="caption">(\#fig:plot-ads)Spectral reflectance plot using VisNIR data.</p>
</div>

we can also directly predict `ph.h2o_usda.4c1_index` by using:


```r
pmc3 = url(paste0(rep, "pca.ossl/mpca_visnir_kssl_v1.rds"), "rb")
eml4 = url(paste0(rep, "ph.h2o_usda.4c1_index/visnir_mlr..eml_ossl_na_v1.rds"), "rb")
ossl.pca.visnir = readRDS(pmc3)
ossl.model = readRDS(eml4)
pred.ph2 = predict.ossl(t.var="ph.h2o_usda.4c1_index", visnir.raw=asd.raw, 
        ossl.model=ossl.model, spc.type = "visnir", ossl.pca.visnir = ossl.pca.visnir)
pred.ph2$pred
```

```
  pred.mean pred.error lower.1std upper.1std
1  6.565335  0.4353427   6.129993   7.000678
```

We are currently building an API that will work directly with standard raw files 
coming directly from the instruments. This should help make the OSSL more robust 
and applicable to thousands of requests on a daily basis.

Wrongly formatted spectral scans can lead to artifacts and should be used with care. 
Note that complexity of soil spectral scans remains high, including the file sizes that are 
difficult to open and read (few thousands of columns) 
and are often not supported in standard tabular software e.g. LibreOffice or similar. 
We recommend thus to report any issues you might have via our [project GitHub](https://github.com/soilspectroscopy) so we 
can all help each other produce more accurate primary soil data.

## Registering your own model

If you plan to contribute your own models to the Soil Spectroscopy for Global Good project 
please follow these steps:

1. We recommend registering and sharing new models via S3 file 
    service system (e.g. via OpenGeoHub's Wasabi.com cloud-service) with RDS files produced using 
    [Dockerized solution for full scientific reproducibility](https://github.com/nuest/docker-reproducible-research).  
2. For each model the following metadata need to be supplied:
    - Registered [docker image](https://hub.docker.com/r/opengeohub/r-geo); which should specify in detail: software in 
    use, R package versions etc;
    - DOI of the zenodo repository with a back-up for the data (i.e. how to cite your models);
    - URL for accessing the RDS file via S3; 

We can host your models on our infrastructure at no additional costs. Please 
[contact us](https://soilspectroscopy.org/contact/) and apply for registering your models via soilspectroscopy.org.
