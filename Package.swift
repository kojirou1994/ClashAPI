// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "ClashAPI",
  platforms: [
    .macOS(.v10_15)
  ],
  products: [
    .library(name: "ClashAPI", targets: ["ClashAPI"]),
  ],
  dependencies: [
    .package(url: "https://github.com/kojirou1994/Networking.git", from: "0.1.0"),
    .package(url: "https://github.com/kojirou1994/AnyEncodable.git", from: "0.0.1"),
    .package(url: "https://github.com/kojirou1994/Kwift.git", from: "1.0.0"),
    .package(url: "https://github.com/kojirou1994/ProxyUtility.git", from: "0.2.0"),
    .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.2.0"),
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "0.0.1")
  ],
  targets: [
    .target(
      name: "clash-cli",
      dependencies: [
        "ClashAPI",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "AsyncHTTPClient", package: "async-http-client"),
        .product(name: "AsyncHTTPClientNetworking", package: "Networking"),
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
