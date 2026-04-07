import SpriteKit

// MARK: - Gem Colors (6 mineral types)
enum GemColor: Int, CaseIterable, Codable {
    case ruby = 0
    case gold = 1
    case silver = 2
    case emerald = 3
    case sapphire = 4
    case amethyst = 5

    var displayName: String {
        switch self {
        case .ruby: return "Ruby"
        case .gold: return "Gold"
        case .silver: return "Silver"
        case .emerald: return "Emerald"
        case .sapphire: return "Sapphire"
        case .amethyst: return "Amethyst"
        }
    }

    var colorHint: String {
        switch self {
        case .ruby: return "red"
        case .gold: return "gold"
        case .silver: return "silver"
        case .emerald: return "green"
        case .sapphire: return "blue"
        case .amethyst: return "purple"
        }
    }

    var primaryColor: SKColor {
        switch self {
        case .ruby: return SKColor(red: 0.95, green: 0.08, blue: 0.12, alpha: 1.0)       // Vivid red
        case .gold: return SKColor(red: 1.0, green: 0.88, blue: 0.05, alpha: 1.0)
        case .silver: return SKColor(hex: 0xC0C0C0)
        case .emerald: return SKColor(red: 0.05, green: 0.75, blue: 0.28, alpha: 1.0)     // Vivid green
        case .sapphire: return SKColor(red: 0.10, green: 0.25, blue: 0.90, alpha: 1.0)    // Vivid blue
        case .amethyst: return SKColor(red: 0.58, green: 0.12, blue: 0.88, alpha: 1.0)    // Vivid purple
        }
    }

    var lightColor: SKColor {
        switch self {
        case .ruby: return SKColor(red: 1.0, green: 0.45, blue: 0.48, alpha: 1.0)
        case .gold: return SKColor(red: 1.0, green: 1.0, blue: 0.55, alpha: 1.0)
        case .silver: return SKColor(hex: 0xE8E8E8)
        case .emerald: return SKColor(red: 0.30, green: 0.95, blue: 0.55, alpha: 1.0)
        case .sapphire: return SKColor(red: 0.40, green: 0.58, blue: 1.0, alpha: 1.0)
        case .amethyst: return SKColor(red: 0.78, green: 0.45, blue: 1.0, alpha: 1.0)
        }
    }

    var darkColor: SKColor {
        switch self {
        case .ruby: return SKColor(red: 0.50, green: 0.0, blue: 0.04, alpha: 1.0)
        case .gold: return SKColor(red: 0.80, green: 0.58, blue: 0.0, alpha: 1.0)
        case .silver: return SKColor(hex: 0x708090)
        case .emerald: return SKColor(red: 0.0, green: 0.35, blue: 0.10, alpha: 1.0)
        case .sapphire: return SKColor(red: 0.03, green: 0.10, blue: 0.45, alpha: 1.0)
        case .amethyst: return SKColor(red: 0.28, green: 0.04, blue: 0.45, alpha: 1.0)
        }
    }

    func localizedDisplayName(_ lm: LocalizationManager) -> String {
        switch self {
        case .ruby: return lm.t("gem.ruby")
        case .gold: return lm.t("gem.gold")
        case .silver: return lm.t("gem.silver")
        case .emerald: return lm.t("gem.emerald")
        case .sapphire: return lm.t("gem.sapphire")
        case .amethyst: return lm.t("gem.amethyst")
        }
    }

    func localizedColorHint(_ lm: LocalizationManager) -> String {
        switch self {
        case .ruby: return lm.t("gem.hintRed")
        case .gold: return lm.t("gem.hintGold")
        case .silver: return lm.t("gem.hintSilver")
        case .emerald: return lm.t("gem.hintGreen")
        case .sapphire: return lm.t("gem.hintBlue")
        case .amethyst: return lm.t("gem.hintPurple")
        }
    }

    var isMetal: Bool {
        self == .gold || self == .silver
    }

    static func random() -> GemColor {
        // GemColor always has cases, but avoid force unwrap for safety
        allCases.randomElement() ?? .ruby
    }

    static func random(using generator: inout some RandomNumberGenerator) -> GemColor {
        allCases.randomElement(using: &generator) ?? .ruby
    }
}

// MARK: - Special Gem Types
enum SpecialType: Int, Codable, Equatable {
    case none = 0
    case laserHorizontal = 1  // Striped horizontal - clears row
    case laserVertical = 2    // Striped vertical - clears column
    case volatile = 3         // Wrapped - 3x3 explosion (twice)
    case crystalBall = 4      // Color bomb - clears all of one color
    case miningDrone = 5      // Fish - 3 drones seek targets

    var isLaser: Bool {
        self == .laserHorizontal || self == .laserVertical
    }

    var displayName: String {
        switch self {
        case .none: return "Normal"
        case .laserHorizontal: return "Laser Gem (H)"
        case .laserVertical: return "Laser Gem (V)"
        case .volatile: return "Volatile Gem"
        case .crystalBall: return "Crystal Ball"
        case .miningDrone: return "Mining Drone"
        }
    }

    func localizedDisplayName(_ lm: LocalizationManager) -> String {
        switch self {
        case .none: return lm.t("special.normal")
        case .laserHorizontal: return lm.t("special.laserH")
        case .laserVertical: return lm.t("special.laserV")
        case .volatile: return lm.t("special.volatile")
        case .crystalBall: return lm.t("special.crystalBall")
        case .miningDrone: return lm.t("special.miningDrone")
        }
    }
}

// MARK: - Match Patterns
enum MatchPattern: Equatable {
    case three       // 3 in a row - no special created
    case four        // 4 in a row - creates Laser Gem
    case lShape      // L-shape (5 gems) - creates Volatile Gem
    case tShape      // T-shape (5 gems) - creates Volatile Gem
    case five        // 5 in a row - creates Crystal Ball
    case square      // 2x2 square - creates Mining Drone

    var producesSpecial: Bool {
        self != .three
    }

    var priority: Int {
        switch self {
        case .five: return 100
        case .lShape, .tShape: return 80
        case .four: return 60
        case .square: return 40
        case .three: return 20
        }
    }
}
