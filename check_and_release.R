cran_prep <- rhub::check_for_cran()
Sys.sleep(time = 60^2) #go have lunch
capture.output(cran_prep$cran_summary(), file = "cran-comments.md")
# devtools::release()