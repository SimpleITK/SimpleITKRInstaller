## Placing the R commands in a script as it gets too messy
## to do it all on the command line

if (!require(devtools)) {
  ## devtools install
  install.packages("devtools", lib="~/Rlibs", repo="http://cloud.r-project.org/")
}
makej <- as.numeric(Sys.getenv("MAKE_J"))
# deal with missing entries
makej <- max(makej, 1, na.rm=TRUE)

## get the CC and CXX settings so we can set up distcc
RCMD <- file.path(R.home("bin"), "R")
args <- paste("--no-site-file", "--no-environ", "--no-save", 
        "--no-restore", "--quiet", "CMD", "config", collapse=" ")
argscc <- paste(RCMD, args, "CC", collapse=" ")
argscxx <- paste(RCMD, args, "CXX", collapse=" ")

CC <- system(argscc, intern=TRUE)
CXX <- system(argscxx, intern=TRUE)


ITKREPO <- Sys.getenv("ITK_REPOSITORY")
# with distcc it gets too complicated to deal with all the quoting, so
# pass CC and CXX via environment
Sys.setenv(CC = paste("distcc", CC),
           CXX= paste("distcc", CXX),
           RTESTON="ON",
           MAKEJ=makej,
           DITK_REPOSITORY=paste0("-DITK_REPOSITORY=", ITKREPO))

devtools::install("/home/ubuntu/SimpleITKRInstaller")
