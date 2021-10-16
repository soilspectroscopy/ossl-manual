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
