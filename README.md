[![CRAN version](http://www.r-pkg.org/badges/version/pewdata)](https://cran.r-project.org/package=pewdata) ![](http://cranlogs.r-pkg.org/badges/grand-total/pewdata) [![Travis-CI Build Status](https://travis-ci.org/fsolt/pewdata.svg?branch=master)](https://travis-ci.org/fsolt/pewdata)
------------------------------------------------------------------------
pewdata
=========

`pewdata` is an R package that provides reproducible, programmatic access to survey datasets from the [Pew Research Center](http://www.pewresearch.org).

To install:

* the latest released version: `install.packages("pewdata")`
* the latest development version: 

```R
if (!require(ghit)) install.packages("ghit")
ghit::install_github("fsolt/pewdata")
```

Note that `pewdata` depends on the Chrome Dev browser; if you don't already have it installed on your machine, [get it here](https://www.google.com/chrome/dev/).

For more details, check out [the vignette](https://cran.r-project.org/package=pewdata/vignettes/pewdata-vignette.html).
