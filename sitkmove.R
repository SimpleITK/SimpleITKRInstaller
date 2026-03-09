movestuff <- function(builddir, destdir)
{
    print(paste("Moving from", builddir, "to", destdir))
    pkgstuff <- list.files(path=builddir, full.names=TRUE)
    print(paste("Found", length(pkgstuff), "files to move"))
    bn <- basename(pkgstuff)
    print(paste("bn:", bn))
    fulldest <- file.path(destdir, bn)
    print(paste("fulldest:", fulldest))
    file.rename(from=pkgstuff, to=fulldest)
}

args <- commandArgs( TRUE )
src <- args[[1]]
dest <- args[[2]]

movestuff(src, dest)
q(save="no")

