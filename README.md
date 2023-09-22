
# SimpleITKRInstaller

![Build Status](https://github.com/SimpleITK/SimpleITKRInstaller/actions/workflows/main.yml/badge.svg)


A devtools based installer for SimpleITK R installer.

```R
devtools::install_github("SimpleITK/SimpleITKRInstaller")
```
or, turn on mutlicore compilation using

```R
devtools::install_github("SimpleITK/SimpleITKRInstaller", args=c("--configure-vars=MAKEJ=6"))
```

Requires _cmake_ and _git_ in the path.

Tested on Linux and Mac.

# How to Cite

If you find the R version of SimpleITK useful in your research,
support our efforts by citing it as:

R. Beare, B. C. Lowekamp, Z. Yaniv, "Image Segmentation, Registration and Characterization in R with SimpleITK", *J Stat Softw*, 86(8), https://doi.org/10.18637/jss.v086.i08, 2018.
