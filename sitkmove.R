movestuff <- function(builddir, destdir)
{
    pkgstuff <- list.files(path=builddir, full.names=TRUE)
    bn <- basename(pkgstuff)
    fulldest <- file.path(destdir, bn)
    # On non windows platforms cross drive renaming works but not on windows
    if (.Platform$OS.type != "windows") {
        moved <- file.rename(from=pkgstuff, to=fulldest)
        # If not all files were moved, undo those that were and report an error
        if (!all(moved)) {
            file.rename(from=fulldest[moved], to=pkgstuff[moved])
            message("ERROR: failed to move (destination full?): ", paste(pkgstuff[!moved], collapse=", "))
            return(1L)
        }
        return(0L)
    }
    else { # Windows, copy and delete
        copied <- file.copy(from=pkgstuff, to=fulldest, recursive=TRUE)
        if (all(copied)) {
            unlink(pkgstuff[copied], recursive=TRUE)
        # If not all files were copied, undo those that were and report an error
        } else {
            unlink(fulldest[copied], recursive=TRUE)
            message("ERROR: failed to move (destination full?): ", paste(pkgstuff[!copied], collapse=", "))
            return(1L)
        }
        return(0L)
    }
}

args <- commandArgs( TRUE )
src <- args[[1]]
dest <- args[[2]]

quit(save="no", status=movestuff(src, dest))

