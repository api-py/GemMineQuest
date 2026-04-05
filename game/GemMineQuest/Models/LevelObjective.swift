import Foundation

enum LevelObjective: Codable, Equatable {
    case reachScore(target: Int)
    case clearAllOre
    case dropTreasures(count: Int)
    case collectGems(color: GemColor, count: Int)
    case collectSpecials(type: SpecialType, count: Int)

    var displayText: String {
        switch self {
        case .reachScore(let target):
            return "Score \(target) points"
        case .clearAllOre:
            return "Clear all ore veins"
        case .dropTreasures(let count):
            return "Drop \(count) treasure\(count > 1 ? "s" : "") to mine cart"
        case .collectGems(let color, let count):
            return "Collect \(count) \(color.displayName)\(count > 1 ? "s" : "") (\(color.colorHint))"
        case .collectSpecials(let type, let count):
            return "Create \(count) \(type.displayName)\(count > 1 ? "s" : "")"
        }
    }

    var descriptionText: String {
        switch self {
        case .reachScore(let target):
            return "Score at least \(target) points by matching gems"
        case .clearAllOre:
            return "Match gems on ore vein tiles to mine them all"
        case .dropTreasures(let count):
            return "Move \(count) treasure\(count > 1 ? "s" : "") to the mine cart at the bottom"
        case .collectGems(let color, let count):
            return "Match and collect \(count) \(color.displayName) gems (\(color.colorHint))"
        case .collectSpecials(let type, let count):
            return "Create \(count) \(type.displayName) gem\(count > 1 ? "s" : "") through special matches"
        }
    }

    var shortText: String {
        switch self {
        case .reachScore(let target):
            return "\(target) pts"
        case .clearAllOre:
            return "Clear ore"
        case .dropTreasures(let count):
            return "\(count) treasure\(count > 1 ? "s" : "")"
        case .collectGems(let color, let count):
            return "\(count) \(color.displayName)"
        case .collectSpecials(let type, let count):
            return "\(count) \(type.displayName)"
        }
    }

    /// Short text with color hint for in-game display
    var shortTextWithColor: String {
        switch self {
        case .reachScore(let target):
            return "\(target) pts"
        case .clearAllOre:
            return "Clear all ore"
        case .dropTreasures(let count):
            return "\(count) treasure\(count > 1 ? "s" : "")"
        case .collectGems(let color, let count):
            return "\(count) \(color.displayName) (\(color.colorHint))"
        case .collectSpecials(let type, let count):
            return "\(count) \(type.displayName)"
        }
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case type, target, count, color, specialType
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .reachScore(let target):
            try container.encode("reachScore", forKey: .type)
            try container.encode(target, forKey: .target)
        case .clearAllOre:
            try container.encode("clearAllOre", forKey: .type)
        case .dropTreasures(let count):
            try container.encode("dropTreasures", forKey: .type)
            try container.encode(count, forKey: .count)
        case .collectGems(let color, let count):
            try container.encode("collectGems", forKey: .type)
            try container.encode(color, forKey: .color)
            try container.encode(count, forKey: .count)
        case .collectSpecials(let type, let count):
            try container.encode("collectSpecials", forKey: .type)
            try container.encode(type, forKey: .specialType)
            try container.encode(count, forKey: .count)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "reachScore":
            let target = try container.decode(Int.self, forKey: .target)
            guard target > 0 else {
                throw DecodingError.dataCorruptedError(forKey: .target, in: container, debugDescription: "Target score must be positive")
            }
            self = .reachScore(target: target)
        case "clearAllOre":
            self = .clearAllOre
        case "dropTreasures":
            let count = try container.decode(Int.self, forKey: .count)
            guard count > 0 else {
                throw DecodingError.dataCorruptedError(forKey: .count, in: container, debugDescription: "Treasure count must be positive")
            }
            self = .dropTreasures(count: count)
        case "collectGems":
            let color = try container.decode(GemColor.self, forKey: .color)
            let count = try container.decode(Int.self, forKey: .count)
            guard count > 0 else {
                throw DecodingError.dataCorruptedError(forKey: .count, in: container, debugDescription: "Gem count must be positive")
            }
            self = .collectGems(color: color, count: count)
        case "collectSpecials":
            let specialType = try container.decode(SpecialType.self, forKey: .specialType)
            let count = try container.decode(Int.self, forKey: .count)
            guard count > 0 else {
                throw DecodingError.dataCorruptedError(forKey: .count, in: container, debugDescription: "Special count must be positive")
            }
            self = .collectSpecials(type: specialType, count: count)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown objective type: \(type)")
        }
    }
}
