// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JSBottomSheet",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "JSBottomSheet",
            targets: ["JSBottomSheet"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/wlsdms0122/Stylish.git", from: "3.0.1")
    ],
    targets: [
        .target(
            name: "JSBottomSheet",
            dependencies: [
                "Stylish"
            ]
        ),
        .testTarget(
            name: "JSBottomSheetTests",
            dependencies: [
                "JSBottomSheet"
            ]
        ),
    ]
)
