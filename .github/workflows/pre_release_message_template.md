**Please manually upload the artifacts from [CircleCI](https://dl.circleci.com/status-badge/redirect/gh/SimpleITK/SimpleITKRInstaller/tree/main), review and test the packages before publishing this release. Then remove this line and make it public.**

Detailed release notes are available on the [main SimpleITK repository](https://github.com/SimpleITK/SimpleITK/releases/{{VERSION}}).


Install the package directly from this page, using the URL to the asset which matches your OS and R version:

```r
install.packages("https://github.com/SimpleITK/SimpleITKRInstaller/releases/download/{{VERSION}}/PACKAGE_FILE", repos = NULL, type = "source")
```

**Linux GLIBC compatibility note:** The Linux binary package targets GLIBC 2.28, making it compatible with Linux distributions that include GLIBC 2.28 or newer. The oldest supported version per distribution is: Ubuntu 20.04 (Focal Fossa), Debian 10 (Buster), CentOS/RHEL 8, Rocky Linux 8, AlmaLinux 8, Fedora 29, openSUSE Leap 15.3.

If you need a custom build of SimpleITK or the binary package for your platform, R version, or desired SimpleITK version is not available you will need to build the package yourself. To do this, use the [remotes based installer](https://github.com/SimpleITK/SimpleITKRInstaller).
