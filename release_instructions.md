# Release Instructions

This document describes the steps to create a binary R release for SimpleITK.

## Branch and versioning strategy

- `main` always tracks the highest stable SimpleITK release by semantic version.
- All locally created branches are pushed directly to the authoritative repository.
- Short-lived branches, cut from `main`, are used for all new work.
- Long-lived `release-major.minor` branches created only for old maintenance series (e.g. `release-2.5` after `main` has moved to 3.0) to provide a safe PR target. They are never merged back into `main`.

---

## Releasing on a short-lived branch

Use this process for all releases where `main` is at the same or lower version than the target (e.g. v3.0.0b1, v3.0.0, or v3.0.1 while 3.0 is the leading series).

1. Create a short-lived branch from `main` and switch to it:

    ```
    git checkout main
    git pull https://github.com/SimpleITK/SimpleITKRInstaller.git main
    git checkout -b release-v3.0.0b1
    ```

1. Update the `DESCRIPTION` file: change `SITK_TARGET` to the desired version (e.g. `v3.0.0b1`) and run the `sitk_r_version_date.sh` script.

1. Commit and push:

    ```
    git commit -am "Update SimpleITK to v3.0.0b1"
    git push https://github.com/SimpleITK/SimpleITKRInstaller.git release-v3.0.0b1
    ```

1. On GitHub open a PR targeting `main`. Verify all builds pass and artifacts are created.

1. Stable release (new highest version) — on GitHub merge the PR (we'll delete the branch later), then tag the HEAD of `main`:

    ```
    git checkout main
    git pull https://github.com/SimpleITK/SimpleITKRInstaller.git main
    git tag -a v3.0.0 -m "Release v3.0.0"
    git push https://github.com/SimpleITK/SimpleITKRInstaller.git v3.0.0
    ```

   Prerelease — on GitHub close the PR without merging, then tag its HEAD:

    ```
    git checkout release-v3.0.0b1
    git pull https://github.com/SimpleITK/SimpleITKRInstaller.git release-v3.0.0b1
    git tag -a v3.0.0b1 -m "Release v3.0.0b1"
    git push https://github.com/SimpleITK/SimpleITKRInstaller.git v3.0.0b1
    ```

   This branch on the authoritative repository will be deleted in the last step; the tag keeps the commit permanently reachable.

1. Monitor the tag-triggered build at https://github.com/SimpleITK/SimpleITKRInstaller/actions. If a build fails due to transient issues, rerun from failed (artifacts from successful builds are retained).

1. Once all builds complete a [draft release](https://github.com/SimpleITK/SimpleITKRInstaller/releases) is created automatically. Verify the expected binary packages are present, test them (download, unzip, rename, install), then publish the release.

1. Delete the short-lived branch:

    ```
    git push https://github.com/SimpleITK/SimpleITKRInstaller.git --delete release-v3.0.0b1
    git branch -d release-v3.0.0b1
    ```

---

## Releasing a patch on an old maintenance series (e.g. v2.5.7 after main is at v3.0.0)

Old maintenance series have a long-lived `release-major.minor` branch as a safe PR target so that old-series patches cannot accidentally be merged into `main`.

### Creating a maintenance branch (one time per series)

If the `release-2.5` branch does not yet exist, cut it from the last stable tag of that series (e.g. `v2.5.6`):

```
git fetch --tags https://github.com/SimpleITK/SimpleITKRInstaller.git
git checkout v2.5.6
git checkout -b release-2.5
git push https://github.com/SimpleITK/SimpleITKRInstaller.git release-2.5
```

### Releasing a patch

1. Create a short-lived branch off the maintenance branch:

    ```
    git checkout release-2.5
    git pull https://github.com/SimpleITK/SimpleITKRInstaller.git release-2.5
    git checkout -b release-v2.5.7
    ```

    > **Note**: this branch carries the CI from `release-2.5`, not current `main`. If CI fixes are needed, apply them to `release-2.5` first.

1. Update the `DESCRIPTION` file: change `SITK_TARGET` to `v2.5.7` and run the `sitk_r_version_date.sh` script.

1. Commit and push:

    ```
    git commit -am "Update SimpleITK to v2.5.7"
    git push https://github.com/SimpleITK/SimpleITKRInstaller.git release-v2.5.7
    ```

1. On GitHub open a PR **targeting `release-2.5`** (not `main`). Verify all builds pass and artifacts are created. Merge into `release-2.5`.

1. Pull the updated maintenance branch and tag its HEAD:

    ```
    git checkout release-2.5
    git pull https://github.com/SimpleITK/SimpleITKRInstaller.git release-2.5
    git tag -a v2.5.7 -m "Release v2.5.7"
    git push https://github.com/SimpleITK/SimpleITKRInstaller.git v2.5.7
    ```

1. Monitor, verify artifacts, and publish the release.

1. Delete the short-lived branch:

    ```
    git push https://github.com/SimpleITK/SimpleITKRInstaller.git --delete release-v2.5.7
    git branch -d release-v2.5.7
    ```
