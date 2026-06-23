# Release Instructions

This document describes the steps required to create the binary R release for SimpleITK which updates and relies on the remotes based SimpleITKRInstaller.

1. Create branch off of `main` and switch to it,  `git checkout -b updateRelease main`.

1. Update the installer `DESCRIPTION` file: change the `SITK_TARGET` field to the desired SimpleITK version (e.g. v2.5.5) and run the version update script (in bash or Git Bash on windows), `sitk_r_version_date.sh`. This script will update the file's `Version` and `Date` fields according to the `SITK_TARGET`.

1. Commit and push changes:
  
    ```
    git commit -am "Update SimpleITK release"
    git push origin updateRelease
    ```

1. On GitHub create a PR, see that all tests pass and binary artifacts are created successfuly. Merge into main.

1. Update local `main` from the remote and check out the `main` branch. Tag it using the **exact tag** you listed in the `SITK_TARGET` and push the tag to this repository.

   ```
   git tag v2.5.5
   git push https://github.com/SimpleITK/SimpleITKRInstaller.git v2.5.5
   ```

1. Monitor the build process, https://github.com/SimpleITK/SimpleITKRInstaller/actions. If a build fails due to transient issues, rerun from failed (binary artifacts created for successful builds are retained across reruns). 

1. Once all builds complete successfully a [draft release](https://github.com/SimpleITK/SimpleITKRInstaller/releases) is automatically created. Verify that the expected binary packages are available as release artifacts and test them (download, unzip, rename and install).

1. Edit and publish the release. Check that the binary distribution is working as expected via the r-universe distribution of the foyer package (follow the usage instructions provided in the GitHub release notes).
