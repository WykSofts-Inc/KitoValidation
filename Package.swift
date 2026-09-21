// swift-tools-version: 5.9
//
//  Package.swift
//  KitoValidation
//
//  Created by Wycliff on 7/7/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//


import PackageDescription

let package = Package(
    name: "KitoValidation",
    platforms: [.iOS(.v17)],
    products: [.library(name: "KitoValidation", targets: ["KitoValidation"])],
    targets: [
        .target(name: "KitoValidation"),
        .testTarget(name: "KitoValidationTests", dependencies: ["KitoValidation"]),
    ]
)
