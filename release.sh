#!/bin/sh
set -euo pipefail

# Check arguments
if [ $# -eq 1 ]; then
    echo "A tag and token argument is needed!(ex: ./release.sh 1.2.3 xxxxxxx)"
    exit 1
fi

lib_name="license-plist"
tag=$1
token=$2
export GITHUB_TOKEN=$token
echo "Tag: '${tag}'"
echo "Token: '${token}'"
filename="${tag}.tar.gz"
echo "Filename: '${filename}'"

# build
make build
zip -j $lib_name.zip ./.build/release/$lib_name

# Prepare artifact bundle
binary_artifact="LicensePlistBinary-macos.artifactbundle.zip"
make spm_artifactbundle_macos
./Tools/update-artifact-bundle.sh "${tag}"

# Push updated binary target definition
git add Package.swift
git commit -m "release ${tag}"
git push origin HEAD

# Push tag
git tag $tag
git push origin $tag

curl -LOk "https://github.com/mono0926/LicensePlist/archive/${filename}"
sha256=$(shasum -a 256 $filename | cut -d ' ' -f 1)
rm $filename

# Homebrew
formula_path="$lib_name.rb"
formula_url="https://api.github.com/repos/mono0926/homebrew-$lib_name/contents/$formula_path"
sha=`curl GET $formula_url \
	| jq -r '.sha'`
echo "sha: \n$sha"
content_encoded=`cat formula.rb.tmpl | sed -e "s/{{TAG}}/$tag/" | sed -e "s/{{SHA256}}/$sha256/" | openssl enc -e -base64 | tr -d '\n '`
echo "content_encoded: \n$content_encoded"

commit_message="Update version to $tag"

curl -i -X PUT $formula_url \
   -H "Content-Type:application/json" \
   -H "Authorization:token $token" \
   -d \
"{
  \"path\":\"$formula_path\",
  \"sha\":\"$sha\",
  \"content\":\"$content_encoded\",
  \"message\":\"$commit_message\"
}"

# GitHub Release
github-release release \
    --user mono0926 \
    --repo LicensePlist \
    --tag $tag

sleep 5

github-release upload \
    --user mono0926 \
    --repo LicensePlist \
    --tag $tag \
    --name "$lib_name.zip" \
    --file $lib_name.zip

rm $lib_name.zip

# Upload artifact bundle
github-release upload \
    --user mono0926 \
    --repo LicensePlist \
    --tag $tag \
    --name $binary_artifact \
    --file $binary_artifact

rm $binary_artifact

# CocoaPods
make portable_zip
portable_zip_name="portable_licenseplist.zip"
github-release upload \
    --user mono0926 \
    --repo LicensePlist \
    --tag $tag \
    --name "$portable_zip_name" \
    --file $portable_zip_name
rm $portable_zip_name

podspec_name="LicensePlist.podspec"
cat "$podspec_name.tmp" | sed s/LATEST_RELEASE_VERSION_NUMBER/$tag/ > "$podspec_name"
pod trunk push $podspec_name --allow-warnings
rm $podspec_name
