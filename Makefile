TEMPORARY_FOLDER?=.build/release
PREFIX?=/usr/local

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
	cp -f "$(TEMPORARY_FOLDER)/LicensePlist" "$(PREFIX)/bin/license-plist"
