# Informal test script for lme4 2.0 structure support
#
# For local development: devtools::load_all(); source("tests/test-lme4-structures.R")
# For R CMD check: runs automatically with installed package
#
# This script tests RLRsim compatibility with lme4 2.0 covariance structures:
# - us()   : unstructured (default, existing behavior)
# - diag() : diagonal (no correlations)
# - cs()   : compound symmetric (equal variances if hom=TRUE, equal correlations)
# - ar1()  : AR(1) autoregressive (homogeneous variance, AR(1) correlation)
#
# Key insight: exactRLRT can only test a SINGLE variance parameter.
# - Correlation parameters (in cs, ar1) are treated as nuisance via pseudo-likelihood
# - Multiple variance parameters require mA/m0 approach to test one at a time

library(RLRsim)
library(lme4)

data(sleepstudy)

cat("=== Testing lme4 2.0 Structure Support ===\n\n")

# =============================================================================
# SINGLE-MODEL TESTS (no mA/m0 needed)
# These test a single variance component directly
# =============================================================================

# Test 1: Traditional syntax (should work as before)
cat("Test 1: Traditional (f|g) syntax - single intercept\n")
m1 <- lmer(Reaction ~ Days + (1 | Subject), data = sleepstudy)
print(exactRLRT(m1, nsim = 1000))

# Test 2: Explicit us() syntax
cat("\nTest 2: Explicit us(f|g) syntax - single intercept\n")
m2 <- lmer(Reaction ~ Days + us(1 | Subject), data = sleepstudy)
print(exactRLRT(m2, nsim = 1000))

# Test 3: diag() syntax - single variance component
cat("\nTest 3: diag(f|g) syntax - single intercept\n")
m3 <- lmer(Reaction ~ Days + diag(1 | Subject), data = sleepstudy)
print(exactRLRT(m3, nsim = 1000))

# Test 4: cs() with hom=TRUE - single variance + correlation (ρ is nuisance)
# This tests whether the shared variance σ² = 0
cat(
  "\nTest 4: cs(f|g, hom=TRUE) syntax - single variance, correlation as nuisance\n"
)
cat(
  "  Note: Tests H0: σ² = 0 where σ² is the common variance for intercept/slope\n"
)
cat("  Correlation ρ is treated as nuisance via pseudo-likelihood\n")
m4 <- lmer(Reaction ~ Days + cs(Days | Subject, hom = TRUE), data = sleepstudy)
print(exactRLRT(m4, nsim = 1000))

# Test 5: ar1() - single variance + AR(1) correlation (ρ is nuisance)
cat(
  "\nTest 5: ar1(f|g) syntax - single variance, AR(1) correlation as nuisance\n"
)
cat("  Note: ar1() requires ordered factor\n")
sleepstudy$DaysF <- ordered(sleepstudy$Days)
m5 <- lmer(Reaction ~ Days + ar1(0 + DaysF | Subject), data = sleepstudy)
print(exactRLRT(m5, nsim = 1000))

# =============================================================================
# mA/m0 TESTS (testing one variance within multi-variance model)
# =============================================================================

# Test 6: diag() syntax - multiple components (need mA/m0)
cat("\nTest 6: diag(f|g) with mA/m0 - testing slope variance\n")
cat("  Model has 2 variances (intercept + slope), testing slope = 0\n")
mA <- lmer(Reaction ~ Days + diag(Days | Subject), data = sleepstudy)
m0 <- lmer(Reaction ~ Days + (1 | Subject), data = sleepstudy)
m_slope <- lmer(Reaction ~ Days + (0 + Days | Subject), data = sleepstudy)
print(exactRLRT(m_slope, mA, m0, nsim = 1000))

# =============================================================================
# FACTOR VARIABLE TESTS
# When using factors, hom=TRUE/FALSE determines if variances are shared
# =============================================================================

# Test 7: cs() with FACTOR and hom=TRUE - single shared variance, should WORK
cat("\nTest 7: cs(factorF|g, hom=TRUE) - factor with homogeneous variance\n")
cat("  All factor levels share ONE variance parameter\n")
m7 <- lmer(
  Reaction ~ Days + cs(0 + DaysF | Subject, hom = TRUE),
  data = sleepstudy
)
print(exactRLRT(m7, nsim = 1000))

# =============================================================================
# EXPECTED FAILURES
# These should fail because they have multiple variance parameters
# =============================================================================

# Test 8: cs() default (hom=FALSE) with continuous - multiple variances, should fail
cat(
  "\nTest 8: cs(f|g) default (hom=FALSE) - SHOULD FAIL (multiple variances)\n"
)
cat(
  "  cs() with hom=FALSE estimates different variance for intercept vs slope\n"
)
tryCatch(
  {
    m8 <- lmer(Reaction ~ Days + cs(Days | Subject), data = sleepstudy)
    result8 <- exactRLRT(m8, nsim = 100)
    stop("ERROR: This should have failed but didn't!")
  },
  error = function(e) {
    if (grepl("multiple random effects", e$message)) {
      cat("  Got expected error: multiple random effects\n")
    } else {
      cat("  Unexpected error:", e$message, "\n")
      stop(e)
    }
  }
)

# Test 9: cs() with FACTOR and hom=FALSE - one variance per level, should FAIL
cat("\nTest 9: cs(factorF|g) default (hom=FALSE) - SHOULD FAIL\n")
cat("  Each factor level gets its own variance parameter\n")
tryCatch(
  {
    m9 <- lmer(Reaction ~ Days + cs(0 + DaysF | Subject), data = sleepstudy)
    result9 <- exactRLRT(m9, nsim = 100)
    stop("ERROR: This should have failed but didn't!")
  },
  error = function(e) {
    if (grepl("multiple random effects", e$message)) {
      cat("  Got expected error: multiple random effects\n")
    } else {
      cat("  Unexpected error:", e$message, "\n")
      stop(e)
    }
  }
)

# Test 10: diag() with FACTOR and hom=FALSE - one variance per level, should FAIL
cat("\nTest 10: diag(factorF|g) default (hom=FALSE) - SHOULD FAIL\n")
cat("  Each factor level gets its own variance parameter (no correlations)\n")
tryCatch(
  {
    m10 <- lmer(Reaction ~ Days + diag(0 + DaysF | Subject), data = sleepstudy)
    result10 <- exactRLRT(m10, nsim = 100)
    stop("ERROR: This should have failed but didn't!")
  },
  error = function(e) {
    if (grepl("multiple random effects", e$message)) {
      cat("  Got expected error: multiple random effects\n")
    } else {
      cat("  Unexpected error:", e$message, "\n")
      stop(e)
    }
  }
)

# =============================================================================
# VarCorr OUTPUT VERIFICATION
# =============================================================================

cat("\n=== VarCorr Output Verification ===\n")

cat("\n(Days|Subject) - unstructured:\n")
m_us <- lmer(Reaction ~ Days + (Days | Subject), data = sleepstudy)
print(VarCorr(m_us))

cat("\ndiag(Days|Subject) - diagonal (no correlation):\n")
m_diag <- lmer(Reaction ~ Days + diag(Days | Subject), data = sleepstudy)
print(VarCorr(m_diag))

cat("\ncs(Days|Subject, hom=TRUE) - compound symmetric, homogeneous:\n")
m_cs_hom <- lmer(
  Reaction ~ Days + cs(Days | Subject, hom = TRUE),
  data = sleepstudy
)
print(VarCorr(m_cs_hom))

cat("\nar1(0+DaysF|Subject) - AR(1):\n")
m_ar1 <- lmer(Reaction ~ Days + ar1(0 + DaysF | Subject), data = sleepstudy)
print(VarCorr(m_ar1))

# =============================================================================
# STRUCTURE DETECTION VERIFICATION
# =============================================================================

cat("\n=== Structure Detection Verification ===\n")

cat("\nTraditional (Days|Subject):\n")
print(RLRsim:::detect_re_structure(m_us))

cat("\ndiag(Days|Subject):\n")
print(RLRsim:::detect_re_structure(m_diag))

cat("\ncs(Days|Subject, hom=TRUE):\n")
print(RLRsim:::detect_re_structure(m_cs_hom))

cat("\nar1(0+DaysF|Subject):\n")
print(RLRsim:::detect_re_structure(m_ar1))

cat("\n=== All Tests Complete ===\n")
