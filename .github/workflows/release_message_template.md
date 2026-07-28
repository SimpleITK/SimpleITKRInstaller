**Please manually upload the artifacts from CircleCI, review and test the packages before publishing this release. Then remove this line and make it public.**

Detailed release notes are available on the [main SimpleITK repository](https://github.com/SimpleITK/SimpleITK/releases/{{VERSION}}).

To install SimpleITK we use a Foyer helper package that downloads the appropriate binary. This is a two step process.

To install the latest SimpleITK version to your primary library directory, first element of `.libPaths()`, run the following:

```r
# install the SimpleITK foyer package
install.packages(
  "SimpleITK.foyer",
  repos = c("https://simpleitk.r-universe.dev"),
  type = "source"
)

# Use foyer to install SimpleITK
library(SimpleITK.foyer)
install_simpleitk()
```
Now you can load the SimpleITK library as usual:

```r
library(SimpleITK)
```

The `install_simpleitk` function provides finer installation control such as SimpleITK version, library installation location and more. To see all options:

```r
help(install_simpleitk)
```

If you directly download the package artifact from this release page, before you install the package you will need to first unzip the file. Then rename it to `SimpleITK_<version>.zip` (windows), `SimpleITK_<version>.tgz` (macOS), or `SimpleITK_<version>.tar.gz` (Linux) to match the expected file name format.

**Linux GLIBC compatibility note:** The Linux binary package targets GLIBC 2.28, making it compatible with Linux distributions that include GLIBC 2.28 or newer. The oldest supported version per distribution is: Ubuntu 20.04 (Focal Fossa), Debian 10 (Buster), CentOS/RHEL 8, Rocky Linux 8, AlmaLinux 8, Fedora 29, openSUSE Leap 15.3.

If you need a custom build of SimpleITK or the binary package for your platform, R version, or desired SimpleITK version is not available you will need to build the package yourself. To do this, use the [remotes based installer](https://github.com/SimpleITK/SimpleITKRInstaller).
