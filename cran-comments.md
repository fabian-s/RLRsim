The package was rejected due to this warning for r-devel-linux-x86_64-debian-clang:

```
/home/hornik/tmp/R.check/r-devel-clang/Work/build/Packages/Rcpp/include/Rcpp/StringTransformer.h:30:40: warning: 'unary_function<const char *, const char *>' is deprecated [-Wdeprecated-declarations] 
```

I cannot replicate this, see e.g.
https://builder.r-hub.io/status/RLRsim_3.1-7.tar.gz-8498c04426f34a3c8ce7c9d28e056e81
so I don't know how to begin to repair it. 
Seems like an Rcpp problem to me, in any case.


