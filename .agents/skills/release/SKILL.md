---
name: release
description: Release LicensePlist to GitHub, Homebrew, and CocoaPods. Automates version bumps, testing, commits, tags, assets, and error recovery.
---

# LicensePlist Release Skill

Automates the complete release process for LicensePlist across GitHub Releases, Homebrew, and CocoaPods.

## Overview & Flow

```
1. Pre-flight checks (main branch, clean git tree, latest commits)
2. Determine new version (x.y.z)
3. Update version in source & test files
4. Run test suite (`swift test`)
5. Commit version bump (`git commit -m "x.y.z" && git push origin main`)
6. Execute release script (`./release.sh x.y.z`)
7. Verify outputs & report completion
```

---

## Detailed Workflow

### 1. Pre-flight Checks
Before starting the release, ensure the repository is in a clean and up-to-date state:

1. **Verify branch is `main`**:
   ```bash
   git branch --show-current
   ```
   If not on `main`, stop and ask the user or switch to `main`.

2. **Verify working tree is clean**:
   ```bash
   git status --porcelain
   ```
   If there are uncommitted changes, do not proceed without addressing them.

3. **Pull latest changes from remote**:
   ```bash
   git pull origin main
   ```

4. **Verify GitHub CLI authentication**:
   ```bash
   env -u GITHUB_TOKEN -u GH_TOKEN gh auth status
   ```

---

### 2. Determine New Version (`x.y.z`)

1. Read the current version from `Sources/LicensePlistCore/Consts.swift`:
   - Locate: `public static let version = "x.y.z"`
2. If the user provided a version argument (e.g. `/release 3.28.1`), use that version.
3. If no version was specified, calculate the next patch version by incrementing the patch number (e.g. `3.28.0` -> `3.28.1`), and confirm with the user.

---

### 3. Update Version in Source & Test Files

Update the version number in the following two files:

1. **`Sources/LicensePlistCore/Consts.swift`**:
   ```swift
   public static let version = "<x.y.z>"
   ```

2. **`Tests/LicensePlistTests/Entity/PlistInfoTests.swift`**:
   ```swift
   LicensePlist Version: <x.y.z>
   ```

---

### 4. Run Test Suite

Verify that all tests pass with the new version:

```bash
swift test
```

Ensure all tests pass before proceeding to commit. If any test fails, resolve the issue before continuing.

---

### 5. Commit Version Bump & Push

Commit the version bump using the project's standard release commit convention:

```bash
git add Sources/LicensePlistCore/Consts.swift Tests/LicensePlistTests/Entity/PlistInfoTests.swift
git commit -m "<x.y.z>"
git push origin main
```

*(Note: `release.sh` expects the version bump commit to be present on `main` before it updates `Package.swift` and creates the release tag.)*

---

### 6. Execute Release Script

Run `./release.sh` with the release version:

```bash
./release.sh <x.y.z>
```

> [!NOTE]
> `release.sh` automatically retrieves the authentication token from `gh auth token` if not provided as the second argument. You do **not** need to pass personal access tokens directly.

#### What `release.sh` does:
1. Builds the main binary (`make build`) and packages `license-plist.zip`
2. Creates the portable zip (`make portable_zip`)
3. Builds the macOS artifact bundle (`make spm_artifactbundle_macos`)
4. Updates binary target URL and checksum in `Package.swift` directly in the git index to avoid premature IDE resolution errors
5. Commits `Package.swift` (`git commit -m "release <x.y.z>"`) and pushes to `origin HEAD`
6. Creates and pushes git tag `<x.y.z>`
7. Computes release archive checksum
8. Updates Homebrew formula in `mono0926/homebrew-license-plist` via GitHub API
9. Creates GitHub Release (`gh release create ... --generate-notes`) automatically generating notes (What's Changed, Contributors, Full Changelog) and attaching:
   - `license-plist.zip`
   - `LicensePlistBinary-macos.artifactbundle.zip`
   - `portable_licenseplist.zip`
10. Synchronizes local `Package.swift`
11. Publishes podspec to CocoaPods Trunk (`pod trunk push`)

---

### 7. Post-Release Verification

1. Verify GitHub Release:
   ```
   https://github.com/mono0926/LicensePlist/releases/tag/<x.y.z>
   ```
2. Verify Homebrew formula update:
   ```
   https://github.com/mono0926/homebrew-license-plist/blob/main/license-plist.rb
   ```
3. Report success to the user with release links.

---

## Troubleshooting & Error Recovery

### A. CocoaPods `pod trunk push` Fails
If `pod trunk push` fails (e.g. due to network timeout or transient CDN error), the rest of the release (Git tag, GitHub Release, Homebrew) has already succeeded. Re-run only the CocoaPods publishing step:

```bash
tag="<x.y.z>"
podspec_name="LicensePlist.podspec"
cat "$podspec_name.tmp" | sed s/LATEST_RELEASE_VERSION_NUMBER/$tag/ > "$podspec_name"
pod trunk push $podspec_name --allow-warnings
rm $podspec_name
```

### B. Git Tag Already Exists
If a previous release attempt failed before `gh release create` and the tag was already pushed:
1. If the tag needs to be reset locally and remotely:
   ```bash
   git tag -d <x.y.z>
   git push origin :refs/tags/<x.y.z>
   ```
2. Or bump to the next patch version and re-run.

### C. Homebrew Formula Update Fails
If `gh api` fails when updating `homebrew-license-plist`:
1. Check GitHub CLI authentication:
   ```bash
   env -u GITHUB_TOKEN -u GH_TOKEN gh auth status
   ```
2. Verify repo access permissions to `mono0926/homebrew-license-plist`.
3. If necessary, manually trigger the Homebrew formula update section from `release.sh`.

### D. Regenerating Release Notes
If release notes need to be re-generated or updated after the release has been published:
```bash
env -u GITHUB_TOKEN -u GH_TOKEN gh release edit "<x.y.z>" --generate-notes
```
