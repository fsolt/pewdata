[![CRAN version](https://www.r-pkg.org/badges/version/pewdata)](https://cran.r-project.org/package=pewdata) ![](https://cranlogs.r-pkg.org/badges/grand-total/pewdata) [![Travis-CI Build Status](https://travis-ci.org/fsolt/pewdata.svg?branch=master)](https://travis-ci.org/fsolt/pewdata)
------------------------------------------------------------------------
pewdata
=========

`pewdata` is an R package that provides reproducible, programmatic access to survey datasets from the [Pew Research Center](http://www.pewresearch.org).

To install:

* the latest released version: `install.packages("pewdata")`
* the latest development version: 

```R
if (!require(remotes)) install.packages("remotes")
remotes::install_github("fsolt/pewdata")
```

Note that `pewdata` depends on the Chrome Dev browser; if you don't already have it installed on your machine, [get it here](https://www.google.com/chrome/dev/).

`pewdata` also depends on having a working installation of `rJava`.  Helpful hints [for Mac users](https://zhiyzuo.github.io/installation-rJava/) and [for Windows users](https://cimentadaj.github.io/blog/2018-05-25-installing-rjava-on-windows-10/installing-rjava-on-windows-10/).

For more details, check out [the vignette](https://cran.r-project.org/package=pewdata/vignettes/pewdata-vignette.html).
