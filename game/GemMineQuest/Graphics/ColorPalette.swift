import SpriteKit

enum ColorPalette {
    // MARK: - UI Theme Colors (Mining)
    static let background = SKColor(hex: 0x1A0F0A)        // Deep cave brown
    static let backgroundGradientTop = SKColor(hex: 0x2D1B12)
    static let backgroundGradientBottom = SKColor(hex: 0x0D0705)
    static let boardBackground = SKColor(hex: 0x3D2B1F, alpha: 0.6)  // Dark wood
    static let tileNormal = SKColor(hex: 0x4A3728, alpha: 0.4)       // Stone brown
    static let tileHighlight = SKColor(hex: 0x6B4F3A, alpha: 0.6)

    // MARK: - Ore & Blockers
    static let oreVein = SKColor(hex: 0xB8860B)           // Dark goldenrod
    static let oreVeinDouble = SKColor(hex: 0xDAA520)     // Goldenrod
    static let granite = SKColor(hex: 0x808080)            // Grey
    static let graniteCracked = SKColor(hex: 0xA0A0A0)
    static let boulder = SKColor(hex: 0x5C4033)            // Dark brown
    static let cage = SKColor(hex: 0x8B8589)               // Iron grey
    static let lava = SKColor(hex: 0xFF4500)               // Orange red
    static let lavaGlow = SKColor(hex: 0xFF6347)
    static let tnt = SKColor(hex: 0xCC0000)                // Dark red
    static let amber = SKColor(hex: 0xFFBF00)              // Amber

    // MARK: - UI Elements
    static let hudBackground = SKColor(hex: 0x2D1B12, alpha: 0.85)
    static let textPrimary = SKColor.white
    static let textSecondary = SKColor(hex: 0xCCBB99)
    static let textGold = SKColor(hex: 0xFFD700)
    static let starFilled = SKColor(hex: 0xFFD700)
    static let starEmpty = SKColor(hex: 0x4A4A4A)
    static let buttonPrimary = SKColor(hex: 0xE8A035)
    static let buttonSecondary = SKColor(hex: 0x6B4F3A)

    // MARK: - Particles
    static let sparkleWhite = SKColor(hex: 0xFFFFF0)
    static let sparkleGold = SKColor(hex: 0xFFD700)
    static let dustBrown = SKColor(hex: 0x8B7355)
    static let mineBlastOrange = SKColor(hex: 0xFF8C00)
}
