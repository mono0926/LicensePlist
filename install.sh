#!/bin/sh
curl "https://api.github.com/repos/mono0926/LicensePlist/releases" \
     | jq -r '.[0].assets_url' \
     | xargs -n1 curl \
     | jq -r '.[0].browser_download_url' \
     | xargs -n1 curl -LOk
unzip license-plist.zip
cp -f license-plist /usr/local/bin/license-plist
echo "Installed at $(which license-plist) 🎉"
