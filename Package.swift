// swift-tools-version:5.5
import PackageDescription

let package = Package(
  name: "RealtimeKitUI",
  platforms: [.iOS(.v13)],
  products: [
    .library(name: "RealtimeKitUI", targets: ["RealtimeKitUI"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/dyte-in/RealtimeKitCoreiOS.git",
      revision: "843c0ec42ed206994f05d55c45e408cff2300300")
  ],
  targets: [
    .target(
      name: "RealtimeKitUI",
      path: "RealtimeKitUI/",
      dependencies: [
        "RealtimeKitCore",
        "DyteWebRTC",
      ],
      resources: [
        .process("Resources/notification_join.mp3"),
        .process("Resources/notification_message.mp3"),
      ])
  ]
)
