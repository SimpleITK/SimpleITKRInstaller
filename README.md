
# SimpleITKRInstaller

![Build Status](https://github.com/SimpleITK/SimpleITKRInstaller/actions/workflows/main.yml/badge.svg)


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


Requires _cmake_ and _git_ in the path.

Tested on Linux and Mac.

# How to Cite

If you find the R version of SimpleITK useful in your research,
support our efforts by citing it as:

R. Beare, B. C. Lowekamp, Z. Yaniv, "Image Segmentation, Registration and Characterization in R with SimpleITK", *J Stat Softw*, 86(8), https://doi.org/10.18637/jss.v086.i08, 2018.
