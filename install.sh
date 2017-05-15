#!/bin/sh
curl "https://api.github.com/repos/mono0926/LicensePlist/releases" \
     | jq -r '.[0].assets_url' \
     | xargs -n1 curl \
     | jq -r '.[0].browser_download_url' \
     | xargs -n1 curl -LOk
unzip license-plist.zip
if [ $? -ne 0 ]
then
    echo "Filed to download the latest executable binary. Maybe the GitHub API limit occurs. Try other installation methods(see: https://github.com/mono0926/LicensePlist#installation )."
    exit 1
fi
cp -f license-plist /usr/local/bin/license-plist
echo "Installed at $(which license-plist) 🎉"
