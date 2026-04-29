#!/bin/bash

set -euo pipefail

readonly version="$1"
readonly artifactbundle="LicensePlistBinary-macos.artifactbundle.zip"
readonly checksum="$(shasum -a 256 "$artifactbundle" | cut -d " " -f1 | xargs)"

readonly package_file="${2:-Package.swift}"

sed -i '' \
  "s/.*\/releases\/download\/.*/            url: \"https:\/\/github.com\/mono0926\/LicensePlist\/releases\/download\/$version\/LicensePlistBinary-macos\.artifactbundle\.zip\",/g" \
  "$package_file"

sed -i '' \
  "s/.*checksum.*/            checksum: \"$checksum\"/g" \
  "$package_file"
