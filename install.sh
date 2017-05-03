#!/bin/sh
cd /tmp
git clone https://github.com/mono0926/LicensePlist.git
cd LicensePlist
git pull
make install
cd -
rm -rf LicensePlist
echo "installed at $(which license-plist)🎉"
