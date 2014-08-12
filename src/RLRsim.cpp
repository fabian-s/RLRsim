// [[Rcpp::depends(Rcpp)]]
#include <Rcpp.h>

using namespace Rcpp  ;

// [[Rcpp::export]]
List RLRsimCpp (
        int p,
        int k,
        int n, 
        int nsim,
        int g,
        int q,
        Rcpp::NumericVector mu,
        Rcpp::NumericVector lambda,
        double lambda0,
        Rcpp::NumericVector xi,
        bool REML) {
            
    Rcpp::RNGScope scope ;
    
    /* allocate: */
    Rcpp::NumericMatrix lambdamu(g, k) ;
    Rcpp::NumericMatrix lambdamuP1(g, k) ;
    Rcpp::NumericMatrix fN(g, k) ;
    Rcpp::NumericMatrix fD(g, k) ;

    Rcpp::NumericVector sumlog1plambdaxi(g) ; 
    Rcpp::NumericVector Chi1(k) ;
    Rcpp::NumericVector res(nsim)  ;
    Rcpp::IntegerVector lambdaind(nsim) ;
    
    int is, ig, ik, dfChiK, n0 ;
    
    double  LR, N, D, ChiK, ChiSum ;
    
    dfChiK = n-p-k; if(dfChiK < 0){ dfChiK = 0; };
    if(REML) {
        n0 = n - p ;
        for(ik=0; ik < k; ++ik){
            xi[ik] = mu[ik] ;
        }
    }	else {
        n0 = n ;
    }
    
    /*precompute stuff that stays constant over simulations*/
    for(ig = 0; ig < g; ++ig) {
        sumlog1plambdaxi[ig] = 0 ;
        for(ik=0 ; ik < k ; ++ik){
            lambdamu(ig, ik) = lambda[ig] * mu[ik] ;
            lambdamuP1(ig, ik) = lambdamu(ig, ik) + 1.0 ;
            
            fN(ig, ik) = ((lambda[ig] - lambda0) * mu[ik]) / lambdamuP1(ig, ik) ;
            fD(ig, ik) = (1 + lambda0 * mu[ik]) / lambdamuP1(ig, ik) ;
            
            sumlog1plambdaxi[ig] += log1p(lambda[ig] * xi[ik]) ;
        }  /* end for k*/
    } /* end for g*/
    
    
    for(is = 0; is < nsim; ++is) {
        /*make random variates, set LR 0*/
        LR =  0 ;
        ChiSum = 0 ;
        ChiK = rchisq(1, dfChiK)[0] ;
        Chi1 = rchisq(k, 1) ;
        if(!REML) {
            ChiSum = std::accumulate(Chi1.begin(), Chi1.end(), 0.0) ;  
        } 

        for(ig = 0; ig < g; ++ig) {  
            /*loop over lambda-grid*/
            N = D = 0 ;
            
            for(ik=0 ; ik < k ; ++ik){ 
                /*loop over mu, xi*/
                N = N + fN(ig, ik) * Chi1[ik] ;
                D = D + fD(ig, ik) * Chi1[ik] ;
            }
            D = D + ChiK ;
            LR = n0 * log1p(N/D) -  sumlog1plambdaxi[ig] ;
            
            if(LR >= res[is]){   
                /*save if LR is bigger than previous LR*/
                res[is] = LR ;
                lambdaind[is] = ig + 1 ;
            } else break ;
        }/*end for g*/

        /* add additional term for LR*/
        if(!REML){
            res[is] = res[is] + n * log1p(rchisq(1, q)[0] / (ChiSum + ChiK)) ;
        }
    }/*end for nsim*/
    
    return List::create(Named("res")=res, 
        Named("lambdaind")=lambdaind,
        Named("lambdamu")=lambdamu, 
        Named("fN")=fN, 
        Named("fD")=fD, 
        Named("sumlog1plambdaxi")=sumlog1plambdaxi, 
        Named("Chi1")=Chi1, 
        Named("ChiK")=ChiK) ;

}
