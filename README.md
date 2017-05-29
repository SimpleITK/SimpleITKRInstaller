# SimpleITKRInstaller
A devtools based installer for SimpleITK R installer.

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

This is caused by a problem with _unzip_ configuration in R.

Test the following steps to rectify.

* Confirm the problem is with devtools by attempting to install devtools
via github:

```R
devtools::install_github("hadley/devtools")
```

* Assuming this fails, check the unzip option in R. A typical response (on Ubuntu)
looks like this. The problem configuration on openSUSE returned an empty string.

```R
options("unzip")
$unzip
[1] "/usr/bin/unzip"
```
Set the unzip option before attempting to use devtools. Ensure that the
path is valid (i.e. unzip is installed):

```R
options(unzip="/usr/bin/zip")
```
