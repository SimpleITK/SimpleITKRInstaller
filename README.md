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

These tricks require _devtools_ to be installed from github (as of June 2017).

Additional cmake can be passed as follows. Multiple arguments should be
separated by an escaped semicolon (\;).
```R
devtools::install_github("SimpleITK/SimpleITKRInstaller",args=c('--configure-vars=MAKEJ=6 CMAKE_EXTRA_FLAGS=-DSimpleITK_4D_IMAGES=ON\\;-DSimpleITK_GIT_PROTOCOL=https'))
```