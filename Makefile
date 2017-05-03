ifeq ($(UNAME), Darwin)
SWIFTC_FLAGS =
LINKER_FLAGS = -Xlinker -L/usr/local/lib
endif
ifeq ($(UNAME), Linux)
SWIFTC_FLAGS = -Xcc -fblocks
LINKER_FLAGS = -Xlinker -rpath -Xlinker .build/debug
PATH_TO_SWIFT = /home/vagrant/swiftenv/versions/$(SWIFT_VERSION)
endif
 
 
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
	cp -f .build/release/LicensePlist /usr/local/bin/license-plist
