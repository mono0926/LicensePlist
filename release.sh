#!/bin/sh
set -euo pipefail

# Check arguments
if [ $# -lt 1 ]; then
    echo "A tag argument is needed!(ex: ./release.sh 1.2.3)"
    exit 1
fi

lib_name="license-plist"
tag=$1
# Token is optional now, will use GITHUB_TOKEN env var if present, or fallback to gh auth
token=${2:-""}
if [ -n "$token" ]; then
    export GITHUB_TOKEN=$token
fi

echo "Tag: '${tag}'"
filename="${tag}.tar.gz"
echo "Filename: '${filename}'"

# build main binary
make build
zip -j $lib_name.zip ./.build/release/$lib_name

# CocoaPods portable zip (MUST BE BEFORE update-artifact-bundle.sh to avoid 404)
make portable_zip
portable_zip_name="portable_licenseplist.zip"

# Prepare artifact bundle
binary_artifact="LicensePlistBinary-macos.artifactbundle.zip"
make spm_artifactbundle_macos
# Update Package.swift in a copy to prevent IDE from resolving 404 URL before release
cp Package.swift Package.swift.release
./Tools/update-artifact-bundle.sh "${tag}" Package.swift.release

# Push updated binary target definition
hash=$(git hash-object -w Package.swift.release)
git update-index --cacheinfo 100644 $hash Package.swift
git commit -m "release ${tag}"
git push origin HEAD

# Push tag
git tag $tag
git push origin $tag

# Wait for GitHub to recognize the tag
sleep 5

curl -LOk "https://github.com/mono0926/LicensePlist/archive/${filename}"
sha256=$(shasum -a 256 $filename | cut -d ' ' -f 1)
rm $filename

# Homebrew
formula_path="$lib_name.rb"
formula_url="https://api.github.com/repos/mono0926/homebrew-$lib_name/contents/$formula_path"

# Use gh api for getting SHA
sha=$(gh api "repos/mono0926/homebrew-$lib_name/contents/$formula_path" --jq '.sha')
echo "sha: $sha"

content_encoded=$(cat formula.rb.tmpl | sed -e "s/{{TAG}}/$tag/" | sed -e "s/{{SHA256}}/$sha256/" | openssl enc -e -base64 | tr -d '\n ')
commit_message="Update version to $tag"

# Use gh api for PUT
gh api --method PUT "repos/mono0926/homebrew-$lib_name/contents/$formula_path" \
   -f message="$commit_message" \
   -f content="$content_encoded" \
   -f sha="$sha"

# GitHub Release with all assets in one go to avoid "immutable release" error
gh release create "$tag" \
    "$lib_name.zip" \
    "$binary_artifact" \
    "$portable_zip_name" \
    --repo mono0926/LicensePlist \
    --title "$tag" \
    --notes "Release $tag"

# Now that release is created, update working directory Package.swift so IDE resolves successfully
mv Package.swift.release Package.swift

# Cleanup local assets
rm $lib_name.zip
rm $binary_artifact
rm $portable_zip_name

# CocoaPods trunk push
podspec_name="LicensePlist.podspec"
cat "$podspec_name.tmp" | sed s/LATEST_RELEASE_VERSION_NUMBER/$tag/ > "$podspec_name"
pod trunk push $podspec_name --allow-warnings
rm $podspec_name
