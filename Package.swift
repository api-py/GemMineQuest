// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GemMineQuest",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "GemMineQuest", targets: ["GemMineQuest"]),
    ],
    targets: [
        .target(
            name: "GemMineQuest",
            dependencies: [],
            path: "game/GemMineQuest",
            exclude: [
                "Assets.xcassets",
                "Info.plist",
                "GemMineQuest.entitlements",
                "App/GemMineQuestApp.swift",
            ],
            sources: [
                "App",
                "GameLogic",
                "Graphics",
                "Localization",
                "Models",
                "Notifications",
                "Persistence",
                "SpriteKit",
                "Utilities",
                "ViewModels",
                "Views",
            ]
        ),
        .testTarget(
            name: "GemMineQuestTests",
            dependencies: ["GemMineQuest"],
            path: "game/GemMineQuestTests"
        ),
    ]
)
