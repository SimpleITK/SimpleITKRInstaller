
# SimpleITKRInstaller

![Build Status](https://github.com/SimpleITK/SimpleITKRInstaller/actions/workflows/main.yml/badge.svg)
[![CircleCI](https://dl.circleci.com/status-badge/img/gh/SimpleITK/SimpleITKRInstaller/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/SimpleITK/SimpleITKRInstaller/tree/main)

A [remotes](https://github.com/r-lib/remotes) based installer for SimpleITK in [R](https://www.r-project.org/).

Default configuration, single core compilation:

```R
remotes::install_github("SimpleITK/SimpleITKRInstaller")
```

Turn on mutlicore compilation, six cores in this example

```R
remotes::install_github("SimpleITK/SimpleITKRInstaller", configure.vars=c("MAKEJ=6"))
```

Use multicore compilation and build additional modules not included in the default build setup such as SimpleElastix (registration) and DCMTK (additional DICOM IO option beyond the default GDCM).

**Note**: We need to use backslashes to escape the spaces in the `ADDITIONAL_SITK_MODULES` otherwise the `remotes::install` does not pass the string correctly to the shell (separates it using the spaces instead of passing as one string).

```R
remotes::install_github("SimpleITK/SimpleITKRInstaller", configure.vars=c("MAKEJ=6", "ADDITIONAL_SITK_MODULES=-DSimpleITK_USE_ELASTIX=ON\\  -DModule_ITKIODCMTK:BOOL=ON"))
```

Note:
On Linux and Mac requires [CMake](https://cmake.org/) and [git](https://git-scm.com/) in the path.

On Windows requires [rtools](https://cran.r-project.org/bin/windows/Rtools/) installation and setting the `RTOOLS_HOME` environment variable. For example:
```R
Sys.setenv(RTOOLS_HOME = "C:/rtools45")
```

# How to Cite

If you find the R version of SimpleITK useful in your research,
support our efforts by citing it as:

R. Beare, B. C. Lowekamp, Z. Yaniv, "Image Segmentation, Registration and Characterization in R with SimpleITK", *J Stat Softw*, 86(8), https://doi.org/10.18637/jss.v086.i08, 2018.
