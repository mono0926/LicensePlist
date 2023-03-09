#!/bin/bash

set -euo pipefail

readonly version="$1"
readonly artifactbundle="LicensePlistBinary-macos.artifactbundle.zip"
readonly checksum="$(shasum -a 256 "$artifactbundle" | cut -d " " -f1 | xargs)"

sed -i '' \
  "s/.*\/releases\/download\/.*/            url: \"https:\/\/github.com\/mono0926\/LicensePlist\/releases\/download\/$version\/LicensePlistBinary-macos\.artifactbundle\.zip\",/g" \
  Package.swift

sed -i '' \
  "s/.*checksum.*/            checksum: \"$checksum\"/g" \
  Package.swift
