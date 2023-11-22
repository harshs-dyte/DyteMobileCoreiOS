// swift-tools-version:5.5
import PackageDescription

// BEGIN KMMBRIDGE VARIABLES BLOCK (do not edit)
let remoteKotlinUrl = "https://dyte-assets.s3.ap-south-1.amazonaws.com/sdk/ios_core/DyteiOSCore-1.25.1-3cd7450e-5ee2-4e9b-adab-f3ece296f594.xcframework.zip"
let remoteKotlinChecksum = "2f6f0917e67f86495e3979d51d8dc0159b3a877aacffd2ad702a60c4710442f9"
let packageName = "DyteiOSCore"
// END KMMBRIDGE BLOCK

let package = Package(
    name: "DyteMobileCoreiOS",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: packageName, targets: [packageName, "WebRTC"]),
    ],
    targets: [
        .binaryTarget(
            name: "WebRTC",
            url: "https://github.com/webrtc-sdk/Specs/releases/download/114.5735.02/WebRTC.xcframework.zip",
            checksum: "c30668eac8f14a21cfb5612ca4e81b10e2d8d8d5e5231c00874ca118eff9a1c0"
        ),
        .binaryTarget(
            name: packageName,
            url: remoteKotlinUrl,
            checksum: remoteKotlinChecksum
        ),
    ]
)

