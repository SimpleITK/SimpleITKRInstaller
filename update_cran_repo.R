#!/usr/bin/env Rscript

# Script to update CRAN-like repository with a package release which points
# to GitHub release assets. This allows us to maintain a CRAN-like website 
# for users to easily install packages while hosting the actual binaries 
# on GitHub releases. The script merges new package entries with existing 
# ones in the PACKAGES file or creates it if it doesn't exist.
#
# CRAN like directory structure using the posit style structure for linux, treat
# it as if it were a source distribution and not binary 
# (https://docs.posit.co/rspm/admin/serving-binaries.html). 
# CRAN does not distribute linux binaries, so nothing to mimic there.
# Each version gets its own directory under the base CRAN directory,
#
# vMAJOR.MINOR.PATCH/
# │
# ├── __linux__/ (using posit structure for source packages)
# │   ├── ubuntu-noble/
# │   │   ├── 4.4
# │   │   └── src/
# │   │       └── contrib/
# │   │           ├── PACKAGES
# │   │           ├── PACKAGES.gz
# │   │           ├── PACKAGES.rds
# │   │           └── package_version.tar.gz (omitted in our case)
# │   ├── rhel9/
# │       ├── 4.4
# │       └── src/
# │           └── contrib/
# │               ├── PACKAGES
# │               ├── PACKAGES.gz
# │               ├── PACKAGES.rds
# │               └── package_version.tar.gz (omitted in our case)
# │
# ├── bin/
#     ├── windows/
#     │   └── contrib/
#     │       └── 4.4/
#     │           ├── PACKAGES
#     │           ├── PACKAGES.gz
#     │           ├── PACKAGES.rds
#     │           └── package_version.zip (omitted in our case)
#     └── macosx/
#         ├── contrib/  (intel)
#         │   └── 4.4/
#         │       ├── PACKAGES
#         │       ├── PACKAGES.gz
#         │       ├── PACKAGES.rds
#         │       └── package_version.tgz (omitted in our case)
#         ├── big-sur-arm64/
#         │   └── contrib/
#         │       └── 4.4/
#         │           ├── PACKAGES
#         │           ├── PACKAGES.gz
#         │           ├── PACKAGES.rds
#         │           └── package_version.tgz (omitted in our case)
#         └── sonoma-arm64/
#             └── contrib/
#                 └── 4.6/
#                     ├── PACKAGES
#                     ├── PACKAGES.gz
#                     ├── PACKAGES.rds
#                     └── package_version.tgz (omitted in our case)
#
#
# Usage:
#   Rscript update_cran_repo.R --packages_dir <path> --base_cran_dir <path> --repo_url <url> --tag <tag>
#
# Arguments:
#   --packages_dir  Directory containing downloaded package files. The package
#                   files are expected to be named in the format:
#                   SimpleITK_{VERSION}_R{R_VERSION}_{PLATFORM}.{extension}
#   --base_cran_dir Base directory for CRAN-like repository (e.g., "docs" for a GitHub pages site)
#   --repo_url      URL of the GitHub repository storing the binary files as release assets (e.g., https://github.com/user/repo)
#   --tag           Release tag name (e.g. v2.5.5)
#
# Example:
#   Rscript update_cran_repo.R \
#     --packages_dir temp_packages \
#     --base_cran_dir docs \
#     --repo_url https://github.com/SimpleITK/SimpleITKRInstaller \
#     --tag v2.5.5

library(tools)

# Utility function to merge and sort package entries
merge_packages <- function(existing_packages, new_package, new_url, version) {
  # Replace or add "File" field from write_PACKAGES with release URL,
  # ensures PACKAGES has a single File entry.
  if (!is.null(colnames(new_package)) && "File" %in% colnames(new_package)) {
    new_package <- new_package[, colnames(new_package) != "File", drop = FALSE]
  }
  new_package <- cbind(new_package, File = new_url)

  # Combine with existing packages
  if (!is.null(existing_packages) && nrow(existing_packages) > 0) {
    # Remove any existing entry for the same version (to handle re-releases)
    existing_packages <- existing_packages[existing_packages[, "Version"] != version, , drop = FALSE]
    all_packages <- rbind(new_package, existing_packages)
  } else {
    all_packages <- new_package
  }
  
  # Sort by version (newest first)
  if (nrow(all_packages) > 1) {
    versions <- package_version(all_packages[, "Version"])
    all_packages <- all_packages[order(versions, decreasing = TRUE), , drop = FALSE]
  }
  
  return(all_packages)
}

# Parse command-line arguments in --key value format
# Takes a character vector of arguments and returns a named list
# Validates that all required arguments are present and that no consecutive keys are present
# Example: c("--packages_dir", "temp", "--tag", "v1.0") -> list("packages_dir" = "temp", "tag" = "v1.0")
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
  # Validate required arguments
  if (!is.null(required_args)) {
    missing_args <- setdiff(required_args, names(parsed))
    if (length(missing_args) > 0) {
      stop("Missing required arguments: ", paste(missing_args, collapse = ", "))
    }
  }
  return(parsed)
}



# Package platform to [repository path, type] mapping
platform_map <- list(
  "windows-x86_64" = list(path = "bin/windows/contrib", type = "win.binary"),
  "macos-x86_64"   = list(path = "bin/macosx/contrib", type = "mac.binary"),
  "macos-arm64"    = list(path = "bin/macosx/big-sur-arm64/contrib", type = "mac.binary"),
  "linux-x86_64"   = list(path = "__linux__/ubuntu-noble", type = "source")
)

# Expected package filename pattern
package_pattern <- "^SimpleITK_([^_]+)_R([0-9]+\\.[0-9]+)_([^\\.]+)\\.(.*)$"

# Parse command line arguments
args <- commandArgs(trailingOnly = TRUE)
parsed_args <- parse_args(args, required_args = c("packages_dir", "base_cran_dir", "repo_url", "tag"))

packages_dir <- parsed_args[["packages_dir"]]
base_cran_dir <- parsed_args[["base_cran_dir"]]
repo_url <- parsed_args[["repo_url"]]
tag <- parsed_args[["tag"]]
effective_base_cran_dir <- file.path(base_cran_dir, tag)

# Validate packages directory exists
if (!dir.exists(packages_dir)) {
  quit(save = "no", status = 0)
}

# Get all files in packages_dir that match the expected pattern
all_files <- list.files(packages_dir, full.names = TRUE)
files <- all_files[grepl(package_pattern, basename(all_files))]

for (file in files) {
  tryCatch({
    filename <- basename(file)
    
    matches <- regmatches(filename, regexec(package_pattern, filename))[[1]]
    version <- matches[2]
    r_version <- matches[3]
    platform <- matches[4]
    extension <- matches[5]

    if (!platform %in% names(platform_map)) {
      message("Unknown platform: ", platform)
      next
    }
    
    # Create destination directory
    platform_info <- platform_map[[platform]]
    dest_dir <- if (platform_info$type == "source") {
      file.path(effective_base_cran_dir, platform_info$path, r_version, "src", "contrib")
    } else {
      file.path(effective_base_cran_dir, platform_info$path, r_version)
    }
    dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)
    
    # Read existing PACKAGES file BEFORE it gets overwritten
    packages_file <- file.path(dest_dir, "PACKAGES")
    existing_packages <- if (file.exists(packages_file)) {
      read.dcf(packages_file)
    } else {
      NULL
    }
    
    # Copy file temporarily to generate PACKAGES metadata
    cleaned_name <- sprintf("SimpleITK_%s.%s", version, extension)
    temp_dest <- file.path(dest_dir, cleaned_name)
    if (!file.copy(file, temp_dest, overwrite = TRUE)) {
      stop(sprintf("Failed to copy %s to %s", file, temp_dest))
    }
    
    # Generate PACKAGES file with metadata from the binary (this overwrites existing)
    write_PACKAGES(dest_dir, type = platform_map[[platform]]$type, latestOnly = FALSE)

    # Read the newly generated package entry
    new_package <- read.dcf(packages_file)
    
    # Merge with existing packages and sort, also adds 
    # the File field using GitHub URL
    merged_packages <- merge_packages(existing_packages, 
                                      new_package, 
                                      sprintf("%s/releases/download/%s/%s", repo_url, tag, filename), 
                                      version)
    
    # Write merged PACKAGES file
    write.dcf(merged_packages, packages_file)
    
    # Generate compressed version
    gzf <- gzfile(file.path(dest_dir, "PACKAGES.gz"), "w")
    write.dcf(merged_packages, gzf)
    close(gzf)
    
    # Generate PACKAGES.rds version
    saveRDS(merged_packages, file.path(dest_dir, "PACKAGES.rds"), version = 2)
    
    # Remove the temporary binary package file from the CRAN-like directory
    unlink(temp_dest)
  }, error = function(e) {
    message(sprintf("Error processing file %s: %s", file, e$message))
    quit(save = "no", status = 1)
  })
}


