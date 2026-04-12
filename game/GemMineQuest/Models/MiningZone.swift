import SwiftUI

/// Represents the 7 Welsh mining regions that form the game's zone progression.
/// Each zone maps to a real Welsh mining location, mineral focus, and mythology connection.
enum MiningZone: Int, CaseIterable {
    case greatOrme = 1       // Bronze Age copper (4,000 years old)
    case southWalesCoalfields // Industrial era coal
    case parysMountain       // 18th century copper, Mars-like landscape
    case llechweddSlate      // UNESCO heritage slate
    case dolgellauGold       // Royal wedding gold
    case dolaucothiRoman     // Roman gold mines (2,000 years old)
    case dinasEmrys          // Dragon's lair / Annwn (Otherworld)

    /// Level range for this zone
    var levelRange: ClosedRange<Int> {
        switch self {
        case .greatOrme:           return 1...30
        case .southWalesCoalfields: return 31...60
        case .parysMountain:       return 61...90
        case .llechweddSlate:      return 91...120
        case .dolgellauGold:       return 121...150
        case .dolaucothiRoman:     return 151...180
        case .dinasEmrys:          return 181...999
        }
    }

    /// Returns the zone for a given level number
    static func zone(for level: Int) -> MiningZone {
        switch level {
        case 1...30:   return .greatOrme
        case 31...60:  return .southWalesCoalfields
        case 61...90:  return .parysMountain
        case 91...120: return .llechweddSlate
        case 121...150: return .dolgellauGold
        case 151...180: return .dolaucothiRoman
        default:       return .dinasEmrys
        }
    }

    /// Localization key for zone display name
    var displayNameKey: String {
        "zone.\(rawValue).name"
    }

    /// Localization key for zone Welsh subtitle
    var welshSubtitleKey: String {
        "zone.\(rawValue).welsh"
    }

    /// Localization key for zone tagline
    var taglineKey: String {
        "zone.\(rawValue).tagline"
    }

    /// Accent color for this zone's UI elements
    var accentColor: Color {
        switch self {
        case .greatOrme:           return Color(red: 0.72, green: 0.45, blue: 0.20) // Copper brown
        case .southWalesCoalfields: return Color(red: 0.85, green: 0.65, blue: 0.13) // Amber lamplight
        case .parysMountain:       return Color(red: 0.40, green: 0.70, blue: 0.40) // Copper green
        case .llechweddSlate:      return Color(red: 0.45, green: 0.52, blue: 0.68) // Slate blue
        case .dolgellauGold:       return Color(red: 1.00, green: 0.84, blue: 0.00) // Rich gold
        case .dolaucothiRoman:     return Color(red: 0.60, green: 0.40, blue: 0.70) // Imperial purple
        case .dinasEmrys:          return Color(red: 0.85, green: 0.12, blue: 0.12) // Dragon red
        }
    }

    /// Background image name for this zone
    var backgroundImageName: String {
        switch self {
        case .greatOrme:           return "bg_zone_great_orme"
        case .southWalesCoalfields: return "bg_zone_south_wales_coal"
        case .parysMountain:       return "bg_zone_parys_mountain"
        case .llechweddSlate:      return "bg_zone_llechwedd_slate"
        case .dolgellauGold:       return "bg_zone_dolgellau_gold"
        case .dolaucothiRoman:     return "bg_zone_dolaucothi_roman"
        case .dinasEmrys:          return "bg_zone_dinas_emrys"
        }
    }

    /// Zone header icon name
    var iconName: String {
        switch self {
        case .greatOrme:           return "zone_icon_great_orme"
        case .southWalesCoalfields: return "zone_icon_south_wales_coal"
        case .parysMountain:       return "zone_icon_parys_mountain"
        case .llechweddSlate:      return "zone_icon_llechwedd_slate"
        case .dolgellauGold:       return "zone_icon_dolgellau_gold"
        case .dolaucothiRoman:     return "zone_icon_dolaucothi_roman"
        case .dinasEmrys:          return "zone_icon_dinas_emrys"
        }
    }

    /// Fallback SF Symbol for zone header when custom icon not available
    var fallbackSystemImage: String {
        switch self {
        case .greatOrme:           return "mountain.2.fill"
        case .southWalesCoalfields: return "flame.fill"
        case .parysMountain:       return "globe.europe.africa.fill"
        case .llechweddSlate:      return "rectangle.stack.fill"
        case .dolgellauGold:       return "crown.fill"
        case .dolaucothiRoman:     return "building.columns.fill"
        case .dinasEmrys:          return "bolt.shield.fill"
        }
    }

    /// The first level of this zone
    var firstLevel: Int {
        levelRange.lowerBound
    }

    /// Whether a given level is the first in its zone
    static func isZoneStart(level: Int) -> Bool {
        for z in MiningZone.allCases {
            if z.firstLevel == level { return true }
        }
        return false
    }
}
