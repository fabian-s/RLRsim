RLRsim
======
  
<!-- badges: start -->
  [![Travis build status](https://travis-ci.org/fabian-s/RLRsim.svg?branch=master)](https://travis-ci.org/fabian-s/RLRsim)
<!-- badges: end -->

R package for fast &amp; exact (restricted) likelihood ratio tests for mixed and additive models.

`RLRsim` implements fast simulation-based exact tests for variance components in mixed and additive models for 
conditionally Gaussian responses -- i.e., tests for questions like: 

* is this random intercept significantly different from 0?
* is this smooth effect significantly nonlinear?
* is this smooth effect significantly different from a constant effect?

The convenience functions `exactRLRT` and `exactLRT` can deal with fitted models from packages `lme4`, `nlme`,  `gamm4` and from `mgcv`'s `gamm()`-function.
Workhorse functions `LRTSim` and `RLRTSim` accept design matrices as inputs directly and can thus be used more generally to generate exact critical values for the corresponding
(restricted) likelihood ratio tests.

The theory behind these tests was first developed in

Crainiceanu, C. and Ruppert, D. (2004) [Likelihood ratio tests in
linear mixed models with one variance component](http://people.orie.cornell.edu/~davidr/papers/asymptoticpaper2.pdf), *Journal of the Royal
Statistical Society: Series B*, **66**,165--185.

Power analyses and sensitivity studies for `RLRsim` can be found in

Scheipl, F., Greven, S. and Kuechenhoff, H. (2008) [Size and power of tests
for a zero random effect variance or polynomial regression in additive and
linear mixed models](http://dx.doi.org/10.1016/j.csda.2007.10.022).  *Computational Statistics &amp; Data Analysis*,
**52**(7):3283--3299.
