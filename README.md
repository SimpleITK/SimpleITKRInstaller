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

