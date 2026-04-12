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
    static let boardBackground = SKColor(red: 0.12, green: 0.10, blue: 0.07, alpha: 1.0)   // Deep mine darkness
    static let tileNormal = SKColor(red: 0.29, green: 0.25, blue: 0.22, alpha: 1.0)       // Torch-lit stone (light)
    static let tileAlternate = SKColor(red: 0.23, green: 0.20, blue: 0.17, alpha: 1.0)    // Deep mine stone (dark)
    static let tileHighlight = SKColor(red: 0.55, green: 0.48, blue: 0.36, alpha: 0.70)

    // MARK: - Board Frame
    static let boardFrameGold = SKColor(hex: 0xC9A84C)
    static let boardFrameGoldDark = SKColor(hex: 0x8B6914)
    static let boardFrameGoldLight = SKColor(hex: 0xF0D68C)

    // MARK: - Tile Bevel
    static let tileBevelLight = SKColor(white: 1.0, alpha: 0.28)    // Strong highlight
    static let tileBevelDark = SKColor(white: 0.0, alpha: 0.28)     // Strong shadow

    // MARK: - Ore & Blockers (Welsh-themed)
    static let oreVein = SKColor(hex: 0xB8860B)
    static let oreVeinDouble = SKColor(hex: 0xDAA520)
    // Slate (was granite) — Welsh slate blue-grey
    static let granite = SKColor(red: 0.42, green: 0.48, blue: 0.55, alpha: 1.0)       // Slate blue-grey
    static let graniteCracked = SKColor(red: 0.55, green: 0.60, blue: 0.66, alpha: 1.0)
    static let graniteLight = SKColor(red: 0.62, green: 0.67, blue: 0.73, alpha: 1.0)
    static let graniteDark = SKColor(red: 0.28, green: 0.32, blue: 0.38, alpha: 1.0)
    // Bluestone (was boulder) — Preseli bluestone tone
    static let boulder = SKColor(red: 0.30, green: 0.38, blue: 0.48, alpha: 1.0)       // Preseli blue
    static let boulderLight = SKColor(red: 0.45, green: 0.52, blue: 0.62, alpha: 1.0)
    // Iron Cage — unchanged but darker
    static let cage = SKColor(hex: 0x6B6569)
    static let cageMetallic = SKColor(hex: 0x909098)
    static let cageRivet = SKColor(hex: 0xC0C0D0)
    // Dragon Fire (was lava) — more intense dragon flame
    static let lava = SKColor(red: 0.95, green: 0.30, blue: 0.05, alpha: 1.0)          // Dragon fire orange
    static let lavaGlow = SKColor(red: 1.00, green: 0.45, blue: 0.15, alpha: 1.0)
    static let lavaYellow = SKColor(red: 1.00, green: 0.85, blue: 0.10, alpha: 1.0)    // Brighter dragon flame
    // Blasting Charge (TNT) — unchanged
    static let tnt = SKColor(hex: 0xCC0000)
    static let tntBand = SKColor(hex: 0x8B4513)
    // Awen Crystal (was amber) — golden inspiration glow
    static let amber = SKColor(red: 1.00, green: 0.78, blue: 0.10, alpha: 1.0)         // Awen golden
    static let amberLight = SKColor(red: 1.00, green: 0.90, blue: 0.45, alpha: 1.0)

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

    // MARK: - Zone Color Palettes
    // Each zone has a distinct color atmosphere reflecting the real Welsh mining region

    struct ZoneColors {
        let backgroundTop: SKColor
        let backgroundBottom: SKColor
        let accent: SKColor
        let tileOverlay: SKColor  // subtle tint over tile background
    }

    /// Returns the color palette for a given mining zone
    static func zoneColors(for zone: MiningZone) -> ZoneColors {
        switch zone {
        case .greatOrme:
            // Warm copper-brown (Bronze Age)
            return ZoneColors(
                backgroundTop: SKColor(red: 0.18, green: 0.12, blue: 0.06, alpha: 1.0),
                backgroundBottom: SKColor(red: 0.10, green: 0.06, blue: 0.03, alpha: 1.0),
                accent: SKColor(red: 0.72, green: 0.45, blue: 0.20, alpha: 1.0),
                tileOverlay: SKColor(red: 0.72, green: 0.45, blue: 0.20, alpha: 0.05)
            )
        case .southWalesCoalfields:
            // Coal-dark grey with amber lamplight
            return ZoneColors(
                backgroundTop: SKColor(red: 0.10, green: 0.10, blue: 0.10, alpha: 1.0),
                backgroundBottom: SKColor(red: 0.05, green: 0.04, blue: 0.03, alpha: 1.0),
                accent: SKColor(red: 0.85, green: 0.65, blue: 0.13, alpha: 1.0),
                tileOverlay: SKColor(red: 0.85, green: 0.65, blue: 0.13, alpha: 0.04)
            )
        case .parysMountain:
            // Vivid copper-green and burnt orange (Mars landscape)
            return ZoneColors(
                backgroundTop: SKColor(red: 0.12, green: 0.10, blue: 0.05, alpha: 1.0),
                backgroundBottom: SKColor(red: 0.08, green: 0.06, blue: 0.03, alpha: 1.0),
                accent: SKColor(red: 0.40, green: 0.70, blue: 0.40, alpha: 1.0),
                tileOverlay: SKColor(red: 0.40, green: 0.70, blue: 0.40, alpha: 0.04)
            )
        case .llechweddSlate:
            // Blue-grey and purple (slate caverns)
            return ZoneColors(
                backgroundTop: SKColor(red: 0.10, green: 0.11, blue: 0.15, alpha: 1.0),
                backgroundBottom: SKColor(red: 0.05, green: 0.05, blue: 0.08, alpha: 1.0),
                accent: SKColor(red: 0.45, green: 0.52, blue: 0.68, alpha: 1.0),
                tileOverlay: SKColor(red: 0.45, green: 0.52, blue: 0.68, alpha: 0.05)
            )
        case .dolgellauGold:
            // Rich golden amber
            return ZoneColors(
                backgroundTop: SKColor(red: 0.15, green: 0.12, blue: 0.05, alpha: 1.0),
                backgroundBottom: SKColor(red: 0.08, green: 0.06, blue: 0.02, alpha: 1.0),
                accent: SKColor(red: 1.00, green: 0.84, blue: 0.00, alpha: 1.0),
                tileOverlay: SKColor(red: 1.00, green: 0.84, blue: 0.00, alpha: 0.04)
            )
        case .dolaucothiRoman:
            // Imperial purple-gold
            return ZoneColors(
                backgroundTop: SKColor(red: 0.12, green: 0.08, blue: 0.14, alpha: 1.0),
                backgroundBottom: SKColor(red: 0.06, green: 0.04, blue: 0.08, alpha: 1.0),
                accent: SKColor(red: 0.60, green: 0.40, blue: 0.70, alpha: 1.0),
                tileOverlay: SKColor(red: 0.60, green: 0.40, blue: 0.70, alpha: 0.04)
            )
        case .dinasEmrys:
            // Dragon-red with mystical blue-white
            return ZoneColors(
                backgroundTop: SKColor(red: 0.15, green: 0.05, blue: 0.05, alpha: 1.0),
                backgroundBottom: SKColor(red: 0.08, green: 0.03, blue: 0.03, alpha: 1.0),
                accent: SKColor(red: 0.85, green: 0.12, blue: 0.12, alpha: 1.0),
                tileOverlay: SKColor(red: 0.85, green: 0.12, blue: 0.12, alpha: 0.05)
            )
        }
    }
}
