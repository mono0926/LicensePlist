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
	mkdir -p "$(PREFIX)/bin"
	cp -f ".build/release/LicensePlist" "$(PREFIX)/bin/license-plist"
