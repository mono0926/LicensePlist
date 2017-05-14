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
	cp -f .build/release/LicensePlist /usr/local/bin/
