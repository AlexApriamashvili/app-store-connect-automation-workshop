// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "hello-appstore",
  platforms: [.macOS(.v14)],

  products: [
    .library(name: "Schema", type: .static, targets: ["Schema"]),
  ],

  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.4.0"),
    .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.0.0"),
    .package(url: "https://github.com/vapor/jwt-kit.git", from: "4.13.0"),
  ],

  targets: [
    .executableTarget(
      name: "hello-appstore",
      dependencies: [
        "Schema",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
        .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
        .product(name: "JWTKit", package: "jwt-kit"),
      ],
      exclude: [
        "openapi-generator-config.yaml",
        "openapi.json",
      ]
    ),
    .target(name: "Schema", path: "Sources/__generated")
  ]
)
