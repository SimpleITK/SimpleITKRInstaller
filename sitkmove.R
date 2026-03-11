movestuff <- function(builddir, destdir)
{
    pkgstuff <- list.files(path=builddir, full.names=TRUE)
    bn <- basename(pkgstuff)
    fulldest <- file.path(destdir, bn)
    file.rename(from=pkgstuff, to=fulldest)
}

args <- commandArgs( TRUE )
src <- args[[1]]
dest <- args[[2]]

movestuff(src, dest)
q(save="no")

