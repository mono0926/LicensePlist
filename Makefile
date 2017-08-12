PREFIX?=/usr/local

TEMPORARY_FOLDER=./tmp_portable_licenseplist

build:
	swift build -c release -Xswiftc -static-stdlib

test:
	swift test

lint:
	swiftlint

clean:
	swift package clean

xcode:
	swift package generate-xcodeproj

install: build
	mkdir -p "$(PREFIX)/bin"
	cp -f ".build/release/LicensePlist" "$(PREFIX)/bin/license-plist"

portable_zip: build
	mkdir "$(TEMPORARY_FOLDER)"
	cp -f ".build/release/LicensePlist" "$(TEMPORARY_FOLDER)"
	cp -f "LICENSE" "$(TEMPORARY_FOLDER)"
	(cd tmp/portable_licenseplist; zip -r - LICENSE LicensePlist) > './portable_licenseplist.zip'
	rm -r "$(TEMPORARY_FOLDER)"
