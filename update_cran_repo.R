#!/usr/bin/env Rscript

# Script to build the SimpleITK foyer package and deploy it to a CRAN-like
# repository structure on gh-pages. The foyer is a lightweight source package
# that, once installed, downloads the actual SimpleITK binary from GitHub
# releases for the user's platform.
#
# The gh-pages CRAN-like structure (source packages only):
#
# src/
# └── contrib/
#     ├── PACKAGES
#     ├── PACKAGES.gz
#     ├── PACKAGES.rds
#     └── SimpleITK.foyer_<version>.tar.gz  (updated with each release)
#
# The foyer package is version-aware and updated with each release.
# Users install it once from a fixed URL, then use install_simpleitk(version=...)
# to download any specific binary version from GitHub Releases.
#
# Usage:
#   Rscript update_cran_repo.R --foyer_dir <path> --output_dir <path> --repo_url <url>
#
# Arguments:
#   --foyer_dir   Directory containing the foyer package template
#   --output_dir  Output directory for the CRAN-like structure (e.g., /tmp/cran_output)
#   --repo_url    URL of the GitHub repository hosting binary releases
#                 (e.g., https://github.com/SimpleITK/SimpleITKRInstaller)
#
# Example:
#   Rscript update_cran_repo.R \
#     --foyer_dir SimpleITK_Foyer \
#     --output_dir /tmp/cran_output \
#     --repo_url https://github.com/SimpleITK/SimpleITKRInstaller

library(tools)

# Parse command-line arguments in --key value format
parse_args <- function(args, required_args = NULL) {
  parsed <- list()
  i <- 1
  while (i <= length(args)) {
    if (startsWith(args[i], "--")) {
      key <- sub("^--", "", args[i])
      if (i < length(args) && !startsWith(args[i + 1], "--")) {
        parsed[[key]] <- args[i + 1]
        i <- i + 2
      } else {
        stop(sprintf("Missing or invalid value for argument: --%s", key))
      }
    } else {
      stop(sprintf("Unexpected argument format: %s (expected a key starting with --)", args[i]))
    }
  }
  if (!is.null(required_args)) {
    missing_args <- setdiff(required_args, names(parsed))
    if (length(missing_args) > 0) {
      stop("Missing required arguments: ", paste(missing_args, collapse = ", "))
    }
  }
  return(parsed)
}

# Parse command line arguments
args <- commandArgs(trailingOnly = TRUE)
parsed_args <- parse_args(args, required_args = c("foyer_dir", "output_dir", "repo_url"))

foyer_dir <- parsed_args[["foyer_dir"]]
output_dir <- parsed_args[["output_dir"]]
repo_url <- parsed_args[["repo_url"]]

# Read version from the DESCRIPTION file of the foyer package
description_file <- file.path(foyer_dir, "DESCRIPTION")
version <- read.dcf(description_file, fields = "Version")[1, 1]

# Validate foyer directory exists
if (!dir.exists(foyer_dir)) {
  stop("Foyer directory does not exist: ", foyer_dir)
}

# Copy foyer template to a temp directory to avoid modifying the original
build_dir <- tempdir()
foyer_copy <- file.path(build_dir, "SimpleITK")
if (dir.exists(foyer_copy)) unlink(foyer_copy, recursive = TRUE)
dir.create(foyer_copy, recursive = TRUE)
file.copy(list.files(foyer_dir, full.names = TRUE), foyer_copy, recursive = TRUE)

# Update repository URL in R/install.R
install_r_path <- file.path(foyer_copy, "R", "install.R")
install_lines <- readLines(install_r_path)

# Update the URL variable
install_lines <- sub(
  '^(\\.sitk_repo_url <- ").*(")',
  paste0("\\1", repo_url, "\\2"),
  install_lines
)

writeLines(install_lines, install_r_path)

# Build the source package
message("Building foyer package...")
# Set tar options to avoid uid/gid warnings when R CMD build creates the tarball.
# --no-same-owner prevents tar from trying to preserve file ownership information,
# which can cause warnings if the original uid/gid values don't exist in the build
# environment. The package installs correctly regardless of these attributes.
Sys.setenv(R_BUILD_TAR = "tar --no-same-owner")
build_output <- system2("R", args = c("CMD", "build", "--no-manual", foyer_copy),
                        stdout = TRUE, stderr = TRUE)
cat(build_output, sep = "\n")

tarball <- sprintf("SimpleITK.foyer_%s.tar.gz", version)
if (!file.exists(tarball)) {
  stop("R CMD build failed. Expected tarball not found: ", tarball)
}

# Create CRAN-like directory structure
dest_dir <- file.path(output_dir, "src", "contrib")
dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)
file.rename(tarball, file.path(dest_dir, tarball))

# Generate PACKAGES files
write_PACKAGES(dest_dir, type = "source")

message("CRAN-like repository created at: ", output_dir)
message("  ", file.path(dest_dir, tarball))
message("  ", file.path(dest_dir, tarball))


