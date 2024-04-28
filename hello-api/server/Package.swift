// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "hello-api-server",
  platforms: [.macOS(.v13)],
  dependencies: [
    .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.4.0"),
    .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.2.0"),
    .package(url: "https://github.com/swift-server/swift-openapi-vapor", from: "1.0.0"),
    .package(url: "https://github.com/vapor/vapor", from: "4.94.0"),
  ],
  targets: [
    .executableTarget(
      name: "hello-api-server",
      dependencies: [
        .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
        .product(name: "OpenAPIVapor", package: "swift-openapi-vapor"),
        .product(name: "Vapor", package: "vapor"),
      ],
      plugins: [
        .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator"),
      ]
    ),
  ]
)
