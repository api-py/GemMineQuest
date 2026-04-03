import SpriteKit

// MARK: - Gem Colors (6 mineral types)
enum GemColor: Int, CaseIterable, Codable {
    case ruby = 0
    case topaz = 1
    case citrine = 2
    case emerald = 3
    case sapphire = 4
    case amethyst = 5

    var displayName: String {
        switch self {
        case .ruby: return "Ruby"
        case .topaz: return "Topaz"
        case .citrine: return "Citrine"
        case .emerald: return "Emerald"
        case .sapphire: return "Sapphire"
        case .amethyst: return "Amethyst"
        }
    }

    var primaryColor: SKColor {
        switch self {
        case .ruby: return SKColor(red: 1.0, green: 0.05, blue: 0.2, alpha: 1.0)         // Vivid red
        case .topaz: return SKColor(red: 1.0, green: 0.55, blue: 0.0, alpha: 1.0)         // Rich orange
        case .citrine: return SKColor(red: 1.0, green: 0.88, blue: 0.0, alpha: 1.0)       // Bright gold
        case .emerald: return SKColor(red: 0.0, green: 0.85, blue: 0.35, alpha: 1.0)      // Vivid green
        case .sapphire: return SKColor(red: 0.1, green: 0.3, blue: 1.0, alpha: 1.0)       // Electric blue
        case .amethyst: return SKColor(red: 0.65, green: 0.2, blue: 1.0, alpha: 1.0)      // Vivid purple
        }
    }

    var lightColor: SKColor {
        switch self {
        case .ruby: return SKColor(red: 1.0, green: 0.5, blue: 0.55, alpha: 1.0)
        case .topaz: return SKColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0)
        case .citrine: return SKColor(red: 1.0, green: 1.0, blue: 0.5, alpha: 1.0)
        case .emerald: return SKColor(red: 0.3, green: 1.0, blue: 0.6, alpha: 1.0)
        case .sapphire: return SKColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0)
        case .amethyst: return SKColor(red: 0.8, green: 0.5, blue: 1.0, alpha: 1.0)
        }
    }

    var darkColor: SKColor {
        switch self {
        case .ruby: return SKColor(red: 0.6, green: 0.0, blue: 0.08, alpha: 1.0)
        case .topaz: return SKColor(red: 0.65, green: 0.3, blue: 0.0, alpha: 1.0)
        case .citrine: return SKColor(red: 0.65, green: 0.55, blue: 0.0, alpha: 1.0)
        case .emerald: return SKColor(red: 0.0, green: 0.45, blue: 0.15, alpha: 1.0)
        case .sapphire: return SKColor(red: 0.04, green: 0.12, blue: 0.55, alpha: 1.0)
        case .amethyst: return SKColor(red: 0.35, green: 0.08, blue: 0.55, alpha: 1.0)
        }
    }

    static func random() -> GemColor {
        allCases.randomElement()!
    }

    static func random(using generator: inout some RandomNumberGenerator) -> GemColor {
        allCases.randomElement(using: &generator)!
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
}
