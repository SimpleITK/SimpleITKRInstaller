# SimpleITKRInstaller

A devtools based installer for the SimpleITK R package for Linux and OSX.

First, install _devtools_ and ensure that it is able to install
packages from github:

```R
install.packages("devtools")
## test that is able to access github by updating itself
devtools::install_github("hadley/devtools")
```

See below if you have problems.

Ensure that _cmake_ and _git_ are in the path.

```R
devtools::install_github("SimpleITK/SimpleITKRInstaller")
```
or, turn on mutlicore compilation using

```R
devtools::install_github("SimpleITK/SimpleITKRInstaller", args=c('--configure-vars="MAKEJ=6"'))
```

Requires _cmake_ and _git_ in the path.

Tested on Linux and Mac.

## Known problems

The following error has been observed on openSUSE:

```R
Downloading github repo SimpleITK/SimpleITKRInstaller@master
Error in system(full, intern = quiet, ignore.stderr = quiet, ...) :
  error in running command
```

or, depending on version:

```R
Downloading GitHub repo SimpleITK/SimpleITKRInstaller@master
from URL https://api.github.com/repos/SimpleITK/SimpleITKRInstaller/zipball/master
Installation failed: error in running command
```

This is caused by a problem with _unzip_ configuration in R.

Test the following steps to rectify.

* Confirm the problem is with devtools by attempting to install devtools
via github:

```R
devtools::install_github("hadley/devtools")
```

* Assuming this fails, check the unzip option in R. The
following indicates a problem:

```R
options("unzip")
$unzip
[1] ""
```
A typical response (on Ubuntu)
looks like this. The problem configuration on openSUSE returned an empty string.

```R
options("unzip")
$unzip
[1] "/usr/bin/unzip"
```

Set the unzip option before attempting to use devtools. Ensure that the
path is valid (i.e. unzip is installed). This is a per-session setting. Investigate
Rprofile settings if you wish to make it permanent:

```R
options(unzip="/usr/bin/zip")
devtools::install_github("SimpleITK/SimpleITKRInstaller")
```
