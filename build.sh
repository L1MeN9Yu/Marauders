#!/bin/bash

set -e

NAME=MaraudersCLI

function build() {
  START=$(date +%s)

  swift build --product $NAME \
    -c release \
    -Xswiftc "-sdk" \
    -Xswiftc "$(xcrun --sdk iphoneos --show-sdk-path)" \
    -Xswiftc "-target" \
    -Xswiftc "arm64-apple-ios10.0" \
    -Xcc "-arch" \
    -Xcc "arm64" \
    -Xcc "--target=arm64-apple-ios10.0" \
    -Xcc "-isysroot" \
    -Xcc "$(xcrun --sdk iphoneos --show-sdk-path)" \
    -Xcc "-mios-version-min=10.0" \
    -Xcc "-miphoneos-version-min=10.0"

  cp .build/release/MaraudersCLI MaraudersCLI.arm64

  swift build --product $NAME \
    -c release \
    -Xswiftc "-sdk" \
    -Xswiftc "$(xcrun --sdk macosx --show-sdk-path)" \
    -Xswiftc "-target" \
    -Xswiftc "x86_64-apple-macos10.10" \
    -Xcc "-arch" \
    -Xcc "x86_64" \
    -Xcc "--target=x86_64-apple-macos10.10" \
    -Xcc "-isysroot" \
    -Xcc "$(xcrun --sdk macosx --show-sdk-path)" \
    -Xcc "-mmacosx-version-min=10.10"

  cp .build/release/MaraudersCLI MaraudersCLI.x86_64

  lipo -create MaraudersCLI.arm64 MaraudersCLI.x86_64 -output MaraudersCLI.universal

  rm MaraudersCLI.arm64 MaraudersCLI.x86_64

  END=$(date +%s)
  TIME=$(($END - $START))
  echo "build in $TIME seconds"
}

function main() {
  build
}

main
