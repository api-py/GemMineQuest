# GemMineQuest

A mining-themed match-3 puzzle game for iOS, built with Swift, SpriteKit, and SwiftUI.

## Requirements

- iOS 17.0+
- Xcode 16.0+

## Build & Run

1. Open `game/GemMineQuest.xcodeproj` in Xcode
2. Select an iOS Simulator or connected device
3. Build and run (Cmd+R)

## Features

- 6 gem types with unique shapes and rich CoreGraphics rendering at 3x Retina
- 5 special gems: Horizontal/Vertical Laser, Volatile (3x3 explosion), Crystal Ball (color clear), Mining Drone
- Full chain reactions between special gems, including drone cascades
- 6 blocker types: Granite (multi-layer), Boulder, Cage, Lava (spreads), TNT (countdown), Amber
- Worm mechanic on every 5th level: worm eats a random gem or blocker every 5 moves
- 200+ procedurally generated levels with difficulty scaling and solvability guarantees
- 5 in-game boosters and 3 pre-game boosters
- Free booster reward every 10 consecutive losses on a level
- Daily login rewards and milestone achievements
- Welsh place names for each level

## Tech Stack

- **SpriteKit** for game board rendering, animations, and particle effects
- **SwiftUI** for menus, HUD overlays, settings, and shop
- **CoreGraphics** for high-resolution gem and tile texture generation
- **CryptoKit** for progress data integrity (HMAC-SHA256)

## License

This project is proprietary software. See [LICENSE](LICENSE) for details.
