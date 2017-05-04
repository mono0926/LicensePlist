# LicensePlist

![platforms](https://img.shields.io/badge/platforms-iOS-333333.svg)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/mono0926/NativePopup/master/LICENSE)
[![Language: Swift](https://img.shields.io/badge/swift-3.1-4BC51D.svg?style=flat)](https://developer.apple.com/swift)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

`LicensePlist` generates iOS license plists for `Settings.bundle`.
`Carthage` and `CocoaPods` are supported.

## Install LicensePlist

### Download the executable binary from [Releases](https://github.com/mono0926/LicensePlist/releases)

Download from [Releases](https://github.com/mono0926/LicensePlist/releases), then copy to `/usr/local/bin/license-plist` etc.

### From Source

Clone the master branch of the repository, then run `make install`.

```sh
$ git clone https://github.com/mono0926/LicensePlist.git
$ make install
```

Or you can also install by one-liner.

```sh
curl -fsSL https://github.com/mono0926/LicensePlist/raw/master/install.sh | sh
```

- **Homebrew**: Not supported yet.
- **Download from [Releases](https://github.com/mono0926/LicensePlist/releases)**: Not supported yet.
    - Dynamic Link Library problem.
