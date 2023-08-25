#!/bin/sh

# Workaround to build MessageKit avoiding problems caused by the old libraries and recent Xcode.
# - carthage build fails on M1 Mac
# - Nimble cannot be built on Xcode 12 or above

set -e

carthage checkout

derived_data_dir="$(mktemp -d -t DerivedData)"
trap "rm -rf '$derived_data_dir'" EXIT

# Workaround for https://github.com/Quick/Nimble/issues/855
sed -i '' -e 's/swiftXCTest/XCTestSwiftSupport/g' Carthage/Checkouts/Nimble/Nimble.xcodeproj/project.pbxproj

build_framework() {
    project="$1"
    scheme="$2"
    name="$3"

    rm -rf "Carthage/Build/iOS/${name}.framework"
    mkdir -p Carthage/Build/iOS
    xcodebuild build \
        -project "$project" \
        -scheme "$scheme" \
        -configuration Debug \
        -derivedDataPath "$derived_data_dir" \
        -sdk iphonesimulator \
        -quiet \
        ONLY_ACTIVE_ARCH=YES \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGN_IDENTITY= \
        CARTHAGE=YES
    mv "${derived_data_dir}/Build/Products/Debug-iphonesimulator/${name}.framework" Carthage/Build/iOS/
}

build_framework Carthage/Checkouts/InputBarAccessoryView/InputBarAccessoryView.xcodeproj InputBarAccessoryView InputBarAccessoryView
build_framework Carthage/Checkouts/Nimble/Nimble.xcodeproj Nimble-iOS Nimble
build_framework Carthage/Checkouts/Quick/Quick.xcodeproj Quick-iOS Quick
