PREFIX?=/usr/local

TEMPORARY_FOLDER=./tmp_portable_licenseplist

build:
	swift build --disable-sandbox -c release

build_portable:
	swift build --disable-sandbox -c release --arch x86_64 --arch arm64

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
	cp -f ".build/release/license-plist" "$(PREFIX)/bin/license-plist"

portable_zip: build_portable
	mkdir -p "$(TEMPORARY_FOLDER)"
	cp -f ".build/apple/Products/Release/license-plist" "$(TEMPORARY_FOLDER)/license-plist"
	cp -f "LICENSE" "$(TEMPORARY_FOLDER)"
	(cd $(TEMPORARY_FOLDER); zip -r - LICENSE license-plist) > "./portable_licenseplist.zip"
	rm -r "$(TEMPORARY_FOLDER)"
