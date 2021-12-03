---
editor_options: 
  markdown: 
    wrap: 72
---

# Reference soil spectroscopy models

The following sections describe steps used to produce OSSL models, which 
are used in the OSSL calibration service and API. For more in-depth insight of 
the modeling steps please refer to the [ossl-models](https://github.com/soilspectroscopy/ossl-models) repository.

## Fitting soil spectroscopy callibrarion models

In this tutorial we use a sample dataset to fit calibration models using MIR and VisNIR spectra 
and combination of additional covariates. For modeling we use the Ensemble Machine Learning 
framework as implemented in the R [mlr](https://mlr.mlr-org.com/) programming environment.

We can explore prediction power of multiple calibration frameworks including:

1. Using only MIR spectra for calibration.
2. Using only VisNIR spectra for calibration.
3. Using combination of MIR and VisNIR spectra.
4. Using combination of MIR and VisNIR spectra + geographic covariates.

The methods 1 & 2 are standard methods described in literature [@malone2021soil]. The method 
3 & 4 are referred to as the _"MIR-VisNIR fusion"_ [@vohland2022quantification].
The method 4 is the _"field-specific calibration approach"_; we refer to it here 
as the _"bundle approach"_ as we basically use all information available 
to help produce best predictions of targeted soil properties.

## Soil spectral calibration using Ensemble Machine Learning



## Predicting values for new spectra



## Calibration of models across different datasets

Soil spectral scans obtained by different spectroscopic instruments often cannot be 
modeled or analyzed together i.e. they require some kind of calibration [@lei2022achieving] 
before one can fit cross-instrument / cross-dataset calibration models.



## Using default OSSL models

OSSL model registry (RDS) S3 file services currently includes large number of 
prediction models fitted for a list of soil properties. The complete list is available [here](https://github.com/soilspectroscopy/ossl-models).


## Registering your own model

If you plan to use the models fitted by the Soil Spectroscopy for Global Good project 
or share your own models please follow these steps:

1. We recommend registration and sharing of new models that runs via S3 file 
    service system (e.g. via OpenGeoHub's Wasabi.com cloud-service) with RDS files / 
    [Dockerized solution for full scientific reproducibility](https://github.com/nuest/docker-reproducible-research).  
2. For each model the following metadata need to be supplied:
    - Registered [docker image](https://hub.docker.com/r/opengeohub/r-geo); which should specify in detail: software in 
    use, R package versions;
    - DOI of the zenodo repository with a back-up for the data (i.e. how to cite your models);
    - URL for accessing the RDS file via S3; 

We can host your models on our infrastructure at no additional costs. Please 
contact us and apply for sharing your models [here](https://soilspectroscopy.org/contact/).
