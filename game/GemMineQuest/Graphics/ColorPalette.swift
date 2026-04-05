import SpriteKit

enum ColorPalette {
    // MARK: - Welsh Flag Colors
    static let welshGreen = SKColor(red: 0.0, green: 0.6, blue: 0.2, alpha: 1.0)
    static let welshRed = SKColor(red: 0.78, green: 0.08, blue: 0.08, alpha: 1.0)
    static let welshWhite = SKColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

    // MARK: - UI Theme Colors (Warm mine shaft palette)
    static let background = SKColor(red: 0.10, green: 0.06, blue: 0.03, alpha: 1.0)       // Warm dark brown
    static let backgroundGradientTop = SKColor(red: 0.15, green: 0.10, blue: 0.05, alpha: 1.0)
    static let backgroundGradientBottom = SKColor(red: 0.06, green: 0.04, blue: 0.02, alpha: 1.0)
    static let boardBackground = SKColor(red: 0.18, green: 0.14, blue: 0.08, alpha: 1.0)   // Solid dark brown
    static let tileNormal = SKColor(red: 0.55, green: 0.46, blue: 0.34, alpha: 1.0)       // Warm amber (full opacity)
    static let tileAlternate = SKColor(red: 0.44, green: 0.37, blue: 0.27, alpha: 1.0)    // Walnut (full opacity)
    static let tileHighlight = SKColor(red: 0.55, green: 0.48, blue: 0.36, alpha: 0.70)

    // MARK: - Board Frame
    static let boardFrameGold = SKColor(hex: 0xC9A84C)
    static let boardFrameGoldDark = SKColor(hex: 0x8B6914)
    static let boardFrameGoldLight = SKColor(hex: 0xF0D68C)

    // MARK: - Tile Bevel
    static let tileBevelLight = SKColor(white: 1.0, alpha: 0.28)    // Strong highlight
    static let tileBevelDark = SKColor(white: 0.0, alpha: 0.28)     // Strong shadow

    // MARK: - Ore & Blockers
    static let oreVein = SKColor(hex: 0xB8860B)
    static let oreVeinDouble = SKColor(hex: 0xDAA520)
    static let granite = SKColor(hex: 0x808080)
    static let graniteCracked = SKColor(hex: 0xA0A0A0)
    static let graniteLight = SKColor(hex: 0xB0B0B0)
    static let graniteDark = SKColor(hex: 0x505050)
    static let boulder = SKColor(hex: 0x5C4033)
    static let boulderLight = SKColor(hex: 0x8B7355)
    static let cage = SKColor(hex: 0x8B8589)
    static let cageMetallic = SKColor(hex: 0xA0A0B0)
    static let cageRivet = SKColor(hex: 0xD0D0E0)
    static let lava = SKColor(hex: 0xFF4500)
    static let lavaGlow = SKColor(hex: 0xFF6347)
    static let lavaYellow = SKColor(hex: 0xFFCC00)
    static let tnt = SKColor(hex: 0xCC0000)
    static let tntBand = SKColor(hex: 0x8B4513)
    static let amber = SKColor(hex: 0xFFBF00)
    static let amberLight = SKColor(hex: 0xFFE066)

    // MARK: - UI Elements
    static let hudBackground = SKColor(red: 0.12, green: 0.09, blue: 0.05, alpha: 0.92)    // Warm brown
    static let textPrimary = welshWhite
    static let textSecondary = SKColor(red: 0.80, green: 0.75, blue: 0.65, alpha: 1.0)     // Warm cream
    static let textGold = SKColor(hex: 0xFFD700)
    static let starFilled = SKColor(hex: 0xFFD700)
    static let starEmpty = SKColor(hex: 0x4A4A4A)
    static let buttonPrimary = welshRed
    static let buttonSecondary = SKColor(red: 0.18, green: 0.14, blue: 0.08, alpha: 1.0)   // Warm dark

    // MARK: - Particles
    static let sparkleWhite = SKColor(hex: 0xFFFFF0)
    static let sparkleGold = SKColor(hex: 0xFFD700)
    static let dustBrown = SKColor(hex: 0x8B7355)
    static let mineBlastOrange = SKColor(hex: 0xFF8C00)
}
