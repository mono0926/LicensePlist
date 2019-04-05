PREFIX?=/usr/local

TEMPORARY_FOLDER=./tmp_portable_licenseplist

build:
	swift build --disable-sandbox -c release

# For CocoaPods distribution
# Works only on Xcode 10.1(Swift 4.2) or earlier
build_legacy:
	swift build --disable-sandbox -c release -Xswiftc -static-stdlib

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

portable_zip: build_legacy
	mkdir -p "$(TEMPORARY_FOLDER)"
	cp -f ".build/release/license-plist" "$(TEMPORARY_FOLDER)/license-plist"
	cp -f "LICENSE" "$(TEMPORARY_FOLDER)"
	(cd $(TEMPORARY_FOLDER); zip -r - LICENSE license-plist) > "./portable_licenseplist.zip"
	rm -r "$(TEMPORARY_FOLDER)"
