RLRsim
======

R package for fast &amp; exact (restricted) likelihood ratio tests for mixed and additive models.

`RLRsim` implements fast simulation-based exact tests for variance components in mixed and additive models for 
conditionally Gaussian responses -- i.e., tests for questions like: 

* is this random intercept significantly different from 0?
* is this smooth effect significantly nonlinear?
* is this smooth effect significantly different from a constant effect?

The convenience functions `exactRLRT` and `exactLRT` can deal with fitted models from `lme4`, `lme` and `gamm4`.
Workhorse functions `LRTSim` and `RLRTSim` accept design matrices as inputs directly and can thus be used more generally.

The theory behind these tests was first developed in

Crainiceanu, C. and Ruppert, D. (2004) Likelihood ratio tests in
linear mixed models with one variance component, *Journal of the Royal
Statistical Society: Series B*, **66**,165--185.

Power analysis and sensitivity studies for `RLRsim` can be found in

Scheipl, F., Greven, S. and Kuechenhoff, H. (2008) Size and power of tests
for a zero random effect variance or polynomial regression in additive and
linear mixed models.  *Computational Statistics &amp; Data Analysis*,
**52**(7):3283--3299.
