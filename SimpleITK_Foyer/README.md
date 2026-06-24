# SimpleITK Foyer Package

This is a lightweight installer package for SimpleITK, providing easy access to pre-built SimpleITK binaries for R.

## Installation

Install the SimpleITK foyer package from r-universe:
```r
install.packages("SimpleITK.foyer",
  repos = "https://simpleitk.r-universe.dev",
  type = "source")
```

Then download and install the **latest** binary package:
```r
library(SimpleITK.foyer)
install_simpleitk()
```

or a specific version: 
```r
library(SimpleITK.foyer)
install_simpleitk(version = "2.5.5")
```

Old versions may not be available, previously not distributed as binaries. In this case you will need to build SimpleITK locally [using the SimpleITKRInstaller](https://github.com/SimpleITK/SimpleITKRInstaller).

After installtion, use SimpleITK as usual:

```r
library(SimpleITK)

img <- ReadImage("path/to/image.dcm")
```

## Rational for using Foyer Package

The full SimpleITK package is quite large (~40-50 MB depending on platform) and requires significant compilation time when built from source. To make it easier for users, we distribute:

1. **This lightweight foyer package** - hosted on the r-universe CRAN-like platform
2. **Pre-built binaries on GitHub Releases** - the actual SimpleITK package

The foyer package installs instantly and provides the `install_simpleitk()` function which downloads the correct pre-built binary for your platform.
