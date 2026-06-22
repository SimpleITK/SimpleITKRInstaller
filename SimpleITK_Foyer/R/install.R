# Base URLs for SimpleITK binary releases.
# These values are updated by the build workflow when generating the foyer package.
.sitk_repo_url <- "https://github.com/SimpleITK/SimpleITKRInstaller"
.sitk_releases_page_url <- paste0(.sitk_repo_url,"/releases")
.sitk_releases_base_url <- paste0(.sitk_releases_page_url,"/download")



#' Install SimpleITK Binary Package
#'
#' Downloads and installs the pre-built SimpleITK binary package for your
#' platform and R version from GitHub releases.
#'
#' @param version Character string specifying the SimpleITK version to install.
#'   Defaults to the version of this foyer package.
#' @param lib Character string specifying the library path where the package
#'   should be installed. Defaults to the first element of \code{.libPaths()}.
#' @param repos Character string specifying alternative repository URL.
#'   By default, uses GitHub releases.
#' @param force Logical. If \code{TRUE}, forces reinstallation even if the
#'   package is already installed.
#' @param quiet Logical. If \code{TRUE}, suppresses progress messages.
#'
#' @return Invisibly returns \code{TRUE} if installation succeeds, 
#'   \code{FALSE} otherwise.
#'
#' @details
#' This function detects your operating system, R version, and architecture,
#' then downloads the appropriate pre-built binary package from the SimpleITK
#' GitHub releases. The binary packages are built by the SimpleITK project
#' and hosted on GitHub releases.
#'
#' Supported platforms:
#' \itemize{
#'   \item Windows x86_64 (R >= 4.0)
#'   \item macOS x86_64 (R >= 4.0)
#'   \item macOS ARM64 (R >= 4.0)
#'   \item Linux x86_64 (R >= 4.0)
#' }
#'
#' @examples
#' \dontrun{
#' # Install SimpleITK for your platform
#' install_simpleitk()
#'
#' # Install a specific version
#' install_simpleitk(version = "2.5.0")
#'
#' # Force reinstallation
#' install_simpleitk(force = TRUE)
#' }
#'
#' @export
install_simpleitk <- function(version = NULL, 
                              lib = .libPaths()[1],
                              repos = NULL,
                              force = FALSE,
                              quiet = FALSE) {
  
  # Check if already installed
  if (!force && requireNamespace("SimpleITK", quietly = TRUE)) {
    if (!quiet) {
      message("SimpleITK is already installed. Use force = TRUE to reinstall.")
    }
    return(invisible(TRUE))
  }
  
  # Get version from latest GitHub release if not specified
  if (is.null(version)) {
    tryCatch({
      # Derive API URL from repo URL
      api_url <- sub("^https://github\\.com/",
                     "https://api.github.com/repos/",
                     .sitk_repo_url)
      api_url <- paste0(api_url, "/releases/latest")

      # Fetch latest release info
      con <- url(api_url, headers = c("User-Agent" = "SimpleITKRInstaller/1.0 R"))
      on.exit(close(con), add = TRUE)
      response <- readLines(con, warn = FALSE)
      json_text <- paste(response, collapse = "")

      # Extract tag_name value from JSON (remove 'v' prefix if present)
      version <- sub('.*"tag_name"\\s*:\\s*"v?([^"]+)".*', '\\1', json_text)

      if (is.null(version) || version == "" || is.na(version) || version == json_text) {
        stop("Could not parse version from GitHub API")
      }

      if (!quiet) {
        message("Using latest version: ", version)
      }
    }, error = function(e) {
      stop("Cannot determine latest SimpleITK version automatically.\n",
           "Please specify version parameter explicitly, e.g., install_simpleitk(version = '2.5.5').\n",
           "Error: ", conditionMessage(e))
    })
  }
  
  # Get R version (major.minor only)
  r_version <- paste(R.version$major, 
                    strsplit(R.version$minor, "\\.")[[1]][1], 
                    sep = ".")
  
  # Detect platform
  platform_info <- get_platform_info()
  
  if (is.null(platform_info)) {
    stop("Unsupported platform. SimpleITK binaries are only available for ",
         "Windows (x86_64), macOS (x86_64, ARM64), and Linux (x86_64).")
  }
  
  # Construct download URL
  if (is.null(repos)) {
    tag <- paste0("v", version)
    filename <- sprintf("SimpleITK_%s_R%s_%s.%s",
                       version, r_version, 
                       platform_info$platform,
                       platform_info$extension)
    download_url <- file.path(.sitk_releases_base_url, tag, filename)
  } else {
    download_url <- file.path(repos, sprintf("SimpleITK_%s.%s", 
                                            version, 
                                            platform_info$extension))
  }
  
  if (!quiet) {
    message("Downloading SimpleITK ", version, " for ", platform_info$platform, 
            " (R ", r_version, ")...")
    message("URL: ", download_url)
  }
  
  # Create temporary directory and file with proper naming
  # R expects package files to be named: PackageName_Version.extension
  temp_dir <- tempfile()
  dir.create(temp_dir, showWarnings = FALSE)
  on.exit(unlink(temp_dir, recursive = TRUE), add = TRUE)

  pkg_filename <- sprintf("SimpleITK_%s.%s", version, platform_info$extension)
  temp_file <- file.path(temp_dir, pkg_filename)
  
  # Download the binary
  tryCatch({
    download.file(download_url, temp_file, mode = "wb", quiet = quiet,
                  headers = c("User-Agent" = "SimpleITKRInstaller/1.0 R"))
  }, error = function(e) {
    stop("Failed to download SimpleITK binary package.\n",
         "URL: ", download_url, "\n",
         "Error: ", conditionMessage(e), "\n",
         "Please check that:\n",
         "  1. You have an internet connection\n",
         "  2. The specified version (", version, ") has pre-built binaries\n",
         "  3. A binary exists for your platform and R version\n",
         "Available releases: ", .sitk_releases_page_url)
  })
  
  if (!quiet) {
    message("Installing SimpleITK package...")
  }
  
  # Install the binary package
  tryCatch({
    install.packages(temp_file, repos = NULL, type = "source", lib = lib,
                    quiet = quiet)
    
    if (!quiet) {
      message("SimpleITK successfully installed!")
      message("Load it with: library(SimpleITK)")
    }
    return(invisible(TRUE))
    
  }, error = function(e) {
    stop("Failed to install SimpleITK binary package.\n",
         "Error: ", conditionMessage(e), "\n",
         "You may need to build from source instead, see ", .sitk_repo_url, ".\n")
  })
}


#' Get Platform Information
#'
#' @return A list with platform and extension, or NULL if unsupported
#' @keywords internal
get_platform_info <- function() {
  os <- Sys.info()["sysname"]
  arch <- Sys.info()["machine"]
  
  # Support both x86_64 and ARM64 architectures
  # Note: Windows may report "x86-64" (with hyphen) or "x86_64" (with underscore)
  is_x86_64 <- grepl("x86[_-]64|amd64", arch, ignore.case = TRUE)
  is_arm64 <- grepl("arm64|aarch64", arch, ignore.case = TRUE)
  
  if (!is_x86_64 && !is_arm64) {
    return(NULL)
  }
  
  if (os == "Windows") {
    return(list(platform = "windows-x86_64", extension = "zip"))
  } else if (os == "Darwin") {
    # macOS: distinguish between x86_64 and ARM64
    if (is_arm64) {
      return(list(platform = "macos-arm64", extension = "tgz"))
    } else {
      return(list(platform = "macos-x86_64", extension = "tgz"))
    }
  } else if (os == "Linux") {
    return(list(platform = "linux-x86_64", extension = "tar.gz"))
  } else {
    return(NULL)
  }
}
