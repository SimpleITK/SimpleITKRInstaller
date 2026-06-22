#' @keywords internal
.onAttach <- function(libname, pkgname) {
  # Check if the full SimpleITK binary is installed
  full_pkg_installed <- tryCatch({
    # Check if the package exists and has the actual SimpleITK functionality
    pkg_path <- system.file(package = "SimpleITK", lib.loc = libname)
    if (pkg_path != "") {
      # Check if it has the core SimpleITK functions (not just this foyer)
      ns <- loadNamespace("SimpleITK")
      exists("Image", envir = ns, mode = "function")
    } else {
      FALSE
    }
  }, error = function(e) FALSE)
  
  if (!full_pkg_installed) {
    packageStartupMessage(
      "================================================================================\n",
      "Welcome to the SimpleITK installer!\n\n",
      "The SimpleITK package is not yet installed.\n",
      "To download and install the latest pre-built binary for your platform, run:\n\n",
      "    install_simpleitk()\n\n",
      "This will download a platform-specific binary from GitHub releases.\n",
      "After installation, load the package with: library(SimpleITK)\n",
      "To download and install a specific SimpleITK version, use: install_simpleitk(version = 'x.y.z')\n",
      "================================================================================"
    )
  }
}
