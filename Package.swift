// swift-tools-version: 5.6

import PackageDescription

let package = Package(
  name: "ClashAPI",
  platforms: [
    .macOS(.v10_15),
  ],
  products: [
    .library(name: "ClashAPI", targets: ["ClashAPI"]),
    .executable(name: "clash-ctl", targets: ["clash-ctl"]),
  ],
  dependencies: [
    .package(url: "https://github.com/kojirou1994/Networking.git", from: "0.4.0"),
    .package(url: "https://github.com/kojirou1994/AnyEncodable.git", from: "0.0.1"),
    .package(url: "https://github.com/kojirou1994/Kwift.git", from: "1.0.0"),
    .package(url: "https://github.com/kojirou1994/ProxyUtility.git", from: "0.2.0"),
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0"),
  ],
  targets: [
    .executableTarget(
      name: "clash-ctl",
      dependencies: [
        "ClashAPI",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "Networking", package: "Networking"),
      ]),
    .target(
      name: "ClashAPI",
      dependencies: [
        .product(name: "ClashSupport", package: "ProxyUtility"),
        .product(name: "Networking", package: "Networking"),
        .product(name: "AnyEncodable", package: "AnyEncodable"),
        .product(name: "KwiftUtility", package: "Kwift"),
      ]),
    .testTarget(
      name: "ClashAPITests",
      dependencies: ["ClashAPI"]),
  ]
)
