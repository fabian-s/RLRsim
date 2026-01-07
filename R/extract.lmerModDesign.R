#' @importFrom stats model.response
#' @importFrom lme4 getME VarCorr
#' @rawNamespace
#' if(getRversion() >= "3.3.0") {
#'   importFrom("stats", sigma)
#' } else {
#'   importFrom("lme4", sigma)
#' }

#' Detect covariance structure type for each random effect term
#' @param m A lmerMod object
#' @return Named character vector with structure types ("us", "diag", "cs", "ar1")
#' @keywords internal
detect_re_structure <- function(m) {
  # Use lme4 2.0 API if available
  if (exists("anyStructured", where = asNamespace("lme4"))) {
    reCovs <- attr(m, "reCovs")
    if (is.null(reCovs)) {
      # Old-style object or us() only
      return(rep("us", getME(m, "n_rtrms")))
    }
    # Map class names to structure types
    sapply(reCovs, function(rc) {
      cls <- class(rc)[1]
      switch(
        cls,
        "Covariance.us" = "us",
        "Covariance.diag" = "diag",
        "Covariance.cs" = "cs",
        "Covariance.ar1" = "ar1",
        "us" # default fallback
      )
    })
  } else {
    # lme4 < 2.0, all structures are implicitly unstructured
    rep("us", getME(m, "n_rtrms"))
  }
}

extract.lmerModDesign <- function(m) {
  X <- getME(m, "X")
  Z <- as.matrix(getME(m, "Z"))
  v <- VarCorr(m)
  resvar <- sigma(m)^2
  Sigma.l <- lapply(v, function(x) x / resvar) #Cov(b)/ Var(Error)
  k <- getME(m, "n_rtrms") #how many grouping factors
  q <- lapply(Sigma.l, NROW) #how many variance components in each grouping factor
  ## OR lapply(m@cnms,length) -- but we should have an extractor for this
  nlevel <- sapply(getME(m, "flist"), function(x) length(levels(x))) #how many inner blocks in Sigma_i
  ## works as is -- but we should have an extractor
  Vr <- matrix(0, NCOL(Z), NCOL(Z)) #Cov(RanEf)/Var(Error)
  from <- 1
  for (i in 1:k) {
    ii <- nlevel[i]
    inner.block <- as.matrix(Sigma.l[[i]])
    to <- from - 1 + ii * NCOL(inner.block)
    Vr[from:to, from:to] <- inner.block %x% diag(ii)
    from <- to + 1
  }
  return(list(
    Vr = Vr, #Cov(RanEf)/Var(Error)
    X = X,
    Z = Z,
    sigmasq = resvar,
    lambda = unique(round(diag(Vr), 10)), # round to handle floating point precision
    y = model.response(model.frame(m)),
    k = k
  ))
}
