
soilspec4gg.init <- function() {
  print('Creating the access for mongodb collections.')
  soilspec4gg.db$collections <<- list(
    soillab = mongo(collection = 'soillab', url = soilspec4gg.db$url, verbose = TRUE),
    soilsite = mongo(collection = 'soilsite', url = soilspec4gg.db$url, verbose = TRUE),
    mir = mongo(collection = 'mir', url = soilspec4gg.db$url, verbose = TRUE),
    visnir = mongo(collection = 'visnir', url = soilspec4gg.db$url, verbose = TRUE)
  )
}

soilspec4gg.samplesById <- function (ids) {

  print('Accessing mongodb collections.')

  query <- to_json( list(
    id_layer_local_c = list("$in"=ids)
  ))

  do.merge <- function(x, y) {
    if (nrow(y) > 0) {
      suppressWarnings(
        merge(x, y, by="id_layer_local_c", all=TRUE),
      )
    } else{
      x
    }
  }

  return(
    Reduce(f = do.merge,
           list(
             soilspec4gg.db$collections$soilsite$find(query = query),
             soilspec4gg.db$collections$soillab$find(query = query),
             soilspec4gg.db$collections$mir$find(query = query),
             soilspec4gg.db$collections$visnir$find(query = query)
           )
    )
  )
}


soc_stock <- function(oc_est.calc_wpct, bd.od_3b2b_gcm3, wpg2_usda_vpct=0, hor.thick_usda_cm=30, oc_est.calc_wpct.sd=10, bd.od_3b2b_gcm3.sd=100, wpg2_usda_vpct.sd=5, se.prop=TRUE){
  if(any(oc_est.calc_wpct[!is.na(oc_est.calc_wpct)]<0)|any(bd.od_3b2b_gcm3[!is.na(bd.od_3b2b_gcm3)]<0)|any(wpg2_usda_vpct[!is.na(wpg2_usda_vpct)]<0)){
    warning("Negative values for 'oc_est.calc_wpct', 'bd.od_3b2b_gcm3', 'wpg2_usda_vpct' found")
  }
  if(any(is.na(bd.od_3b2b_gcm3))){
    ## use PTF to fill-in missing values for BD:
    bd.od_3b2b_gcm3 = ifelse(is.na(bd.od_3b2b_gcm3), 1.38-0.31*log1p(oc_est.calc_wpct/10), bd.od_3b2b_gcm3)
  }
  OCSKG <- oc_est.calc_wpct/1000 * hor.thick_usda_cm/100 * bd.od_3b2b_gcm3 * (100-wpg2_usda_vpct)/100
  if(se.prop==TRUE){
    ## See also: [http://books.google.nl/books?id=C\_XWjSsboeUC]
    OCSKG.sd <- 1E-7*hor.thick_usda_cm*sqrt(bd.od_3b2b_gcm3^2*(100-wpg2_usda_vpct)^2*oc_est.calc_wpct.sd^2 + oc_est.calc_wpct^2*(100-wpg2_usda_vpct)^2*bd.od_3b2b_gcm3.sd^2 + oc_est.calc_wpct^2*bd.od_3b2b_gcm3^2*wpg2_usda_vpct.sd^2)
    ## "kilograms per square-meter"
  }
  return(data.frame(response=OCSKG, sd=OCSKG.sd))
}

saveRDS.gz <- function(object,file,threads=parallel::detectCores()) {
  con <- pipe(paste0("pigz -p",threads," > ",file),"wb")
  saveRDS(object, file = con)
  close(con)
}

readRDS.gz <- function(file,threads=parallel::detectCores()) {
  con <- pipe(paste0("pigz -d -c -p",threads," ",file))
  object <- readRDS(file = con)
  close(con)
  return(object)
}

predict.ossl <- function(t.var, mir.raw, visnir.raw, lon, lat, hzn_depth=10, ossl.model, ossl.pca.mir, ossl.pca.visnir, spc.type="mir", subset.type="ossl", geo.type="na", n.spc=60, sd=TRUE, cog.dir="/data/WORLDCLIM/", ylim=NULL, dataset.code_ascii_c="KSSL.SSL"){ ## =c(0,100)
  ## check that input scans pass some minimum checks
  if(spc.type == "mir" | spc.type == "visnir.mir"){
    if(!any(class(mir.raw)=="data.frame")){
      stop("Input dataset '*.raw' not a correctly formated scan file. See https://soilspectroscopy.github.io/ossl-manual/ for examples.")
    }
    if(nrow(mir.raw)>1000 | ncol(mir.raw)<1400){
      stop("Input dataset '*.raw' dimensions invalid. See https://soilspectroscopy.github.io/ossl-manual/ for examples.")
    }
  }
  if(spc.type == "visnir" | spc.type == "visnir.mir"){
    if(!any(class(visnir.raw)=="data.frame")){
      stop("Input dataset '*.raw' not a correctly formated scan file. See https://soilspectroscopy.github.io/ossl-manual/ for examples.")
    }
    if(nrow(visnir.raw)>1000 | ncol(visnir.raw)<1000){
      stop("Input dataset '*.raw' dimensions invalid. See https://soilspectroscopy.github.io/ossl-manual/ for examples.")
    }
  }
  if(missing(ossl.model)){
    model.rds = paste0("http://s3.us-east-1.wasabisys.com/soilspectroscopy/ossl_models/", t.var, "/", spc.type, "_mlr..eml_", subset.type, "_", geo.type, "_v1.rds")
    ossl.model = readRDS(url(model.rds, "rb"))
  }
  ## convert to PCs
  if(spc.type == "mir" | spc.type == "visnir.mir"){
    wn = as.numeric(gsub("X", "", names(mir.raw)))
    spc = as.matrix(mir.raw)
    #colnames(spc) = paste(wn)
    spc = as.data.frame(prospectr::resample(spc, wn, seq(600, 4000, by=2), interpol = "spline"))
    spc = lapply(spc, function(j){ round(ifelse(j<0, NA, ifelse(j>3, 3, j))*1000) })
    spc = as.data.frame(do.call(cbind, spc))
    names(spc) = paste0("scan_mir.", seq(600, 4000, by=2), "_abs")
    class(ossl.pca.mir) = "prcomp"
    X1.pc = as.data.frame(predict(ossl.pca.mir, newdata=spc))[,1:n.spc]
    colnames(X1.pc) = paste0("mir.PC", 1:n.spc)
  } else {
    X1.pc = NA
  }
  if(spc.type == "visnir" | spc.type == "visnir.mir"){
    wn = as.numeric(gsub("X", "", names(visnir.raw)))
    spc = as.matrix(visnir.raw)
    #colnames(spc) = paste(wn)
    spc = as.data.frame(prospectr::resample(spc, wn, seq(350, 2500, by=2), interpol = "spline"))
    spc = lapply(spc, function(j){ round(ifelse(j<0, NA, ifelse(j>1, 1, j))*100, 1) })
    spc = as.data.frame(do.call(cbind, spc))
    names(spc) = paste0("scan_visnir.", seq(350, 2500, by=2), "_pcnt")
    class(ossl.pca.visnir) = "prcomp"
    X2.pc = as.data.frame(predict(ossl.pca.visnir, newdata=spc))[,1:n.spc]
    colnames(X2.pc) = paste0("visnir.PC", 1:n.spc)
  } else {
    X2.pc = NA
  }
  ## obtain GeoTIFF values
  if(geo.type=="ll"){
    pnts = SpatialPoints(data.frame(lon, lat), proj4string = CRS("EPSG:4326"))
    cog.lst = paste0(cog.dir, ossl.model$features[grep("clm_", ossl.model$features)], ".tif")
    ov.tmp = extract.cog(pnts, cog.lst)
  } else {
    ov.tmp = NA
  }
  ## Bind all covariates together
  X = do.call(cbind, list(X1.pc, X2.pc, ov.tmp, data.frame(hzn_depth=hzn_depth)))
  X = X[,which(unlist(lapply(X, function(x) !all(is.na(x)))))]
  X$dataset.code_ascii_c = factor(rep(dataset.code_ascii_c, nrow(X)), levels = c("NEON.SSL", "KSSL.SSL", "CAF.SSL", "AFSIS1.SSL", "ICRAF.ISRIC", "LUCAS.SSL"))
  X <- fastDummies::dummy_cols(X, select_columns = "dataset.code_ascii_c")
  ## predict
  pred = predict(ossl.model, newdata=X[,ossl.model$features])
  ## uncertainty
  if(sd==TRUE){
    out.c <- as.matrix(as.data.frame(mlr::getStackedBaseLearnerPredictions(ossl.model, newdata=X[,ossl.model$features])))
    cf = eml.cf(ossl.model)
    model.error <- sqrt(matrixStats::rowSds(out.c, na.rm=TRUE)^2 * cf)
  }
  ## Return result as a data.frame:
  out = data.frame(pred.mean=pred$data$response, pred.error=model.error)
  ## back-transform
  if(length(grep("log..", t.var))>0){
    out$tpred.mean = expm1(out$pred.mean)
    if(!is.null(ylim)) {
      out$tpred.mean = ifelse(out$tpred.mean< ylim[1], ylim[1], ifelse(out$tpred.mean > ylim[2], ylim[2], out$tpred.mean))
    }
    out$lower.1std = expm1(out$pred.mean - out$pred.error)
    out$upper.1std = expm1(out$pred.mean + out$pred.error)
  } else {
    out$lower.1std = out$pred.mean - out$pred.error
    out$upper.1std = out$pred.mean + out$pred.error
  }
  if(!is.null(ylim)) {
    out$lower.1std = ifelse(out$lower.1std < ylim[1], ylim[1], ifelse(out$lower.1std > ylim[2], ylim[2], out$lower.1std))
    out$upper.1std = ifelse(out$upper.1std < ylim[1], ylim[1], ifelse(out$upper.1std > ylim[2], ylim[2], out$upper.1std))
  }
  return(list(pred=out, x=X, model=ossl.model$learner.model$super.model$learner.model$model, cf=cf))
}

extract.cog <- function(pnts, cog.lst, url="http://s3.us-east-1.wasabisys.com/soilspectroscopy/layers1km/", mc.cores = 16, local=TRUE){
  if(local==TRUE){
    if(length(pnts)>1){
      ov.tmp = parallel::mclapply(1:length(cog.lst), function(j){ terra::extract(terra::rast(cog.lst[j]), terra::vect(pnts)) }, mc.cores = mc.cores)
    } else {
      ov.tmp = lapply(1:length(cog.lst), function(j){ terra::extract(terra::rast(cog.lst[j]), pnts@coords)})
    }
  } else {
    if(mc.cores>1){
      ov.tmp = parallel::mclapply(1:length(cog.lst), function(j){ terra::extract(terra::rast(paste0("/vsicurl/", url, cog.lst[j])), terra::vect(pnts)) }, mc.cores = mc.cores)
    } else {
      ov.tmp = lapply(1:length(cog.lst), function(j){ terra::extract(terra::rast(paste0("/vsicurl/", url, cog.lst[j])), terra::vect(pnts)) })
    }
  }
  suppressMessages( ov.tmp <- dplyr::bind_cols(lapply(ov.tmp, function(i){i[,2]})) )
  names(ov.tmp) = tools::file_path_sans_ext(basename(cog.lst))
  return(ov.tmp)
}

eml.cf = function(t.m){
  m.train = t.m$learner.model$super.model$learner.model$model
  m.terms = all.vars(t.m$learner.model$super.model$learner.model$terms)
  eml.MSE0 = matrixStats::rowSds(as.matrix(m.train[,m.terms[-1]]), na.rm=TRUE)^2
  eml.MSE = deviance(t.m$learner.model$super.model$learner.model)/df.residual(t.m$learner.model$super.model$learner.model)
  ## correction factor:
  eml.cf = eml.MSE/mean(eml.MSE0, na.rm = TRUE)
  return(eml.cf)
}
