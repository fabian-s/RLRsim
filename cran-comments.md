I see this warning for r-devel-linux-x86_64-debian-clang:

```
/home/hornik/tmp/R.check/r-devel-clang/Work/build/Packages/Rcpp/include/Rcpp/StringTransformer.h:30:40: warning: 'unary_function<const char *, const char *>' is deprecated [-Wdeprecated-declarations] 
```

But since this is Rcpp code, I don't know how to begin to fix this warning in RLRsim.
