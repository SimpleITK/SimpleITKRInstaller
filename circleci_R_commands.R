## Placing the R commands in a script as it gets too messy
## to do it all on the command line

## devtools install
install.packages("devtools", lib="~/Rlibs", repo="http://cloud.r-project.org/")

makej <- as.numeric(Sys.getenv("MAKE_J"))

# set up the configure vars 
configvars <- paste0('--configure-vars="MAKEJ=', makej, ' RTESTON=ON USEDISTCC=1"')
devtools::install("/home/ubuntu/SimpleITKRInstaller", args=configvars)
