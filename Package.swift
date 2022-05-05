// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(name: "SSLog",
                      products: [
                        .library(name: "SSLog", targets: ["SSLog"]),
                      ],
                      dependencies: [
                      ],
                      targets: [
                        .target(name: "SSLog"),
                      ])
