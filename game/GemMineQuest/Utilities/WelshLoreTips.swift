import Foundation

/// Welsh folklore, history, and culture tips displayed before levels and during zone transitions.
/// Each zone has 5 rotating tips that cycle as the player progresses through levels in that zone.
/// Tips are localized via LocalizationManager using keys: lore.zone{N}.tip{0-4}
enum WelshLoreTips {

    /// Returns a localized lore tip for the given level number.
    static func tip(for level: Int, localizationManager: LocalizationManager) -> String {
        let zone = MiningZone.zone(for: level)
        let tipCount = 5
        let index = (level - zone.firstLevel) % tipCount
        return localizationManager.t("lore.zone\(zone.rawValue).tip\(index)")
    }

    /// Returns all localized tips for a given zone.
    static func tips(for zone: MiningZone, localizationManager: LocalizationManager) -> [String] {
        let tipCount = 5
        return (0..<tipCount).map { index in
            localizationManager.t("lore.zone\(zone.rawValue).tip\(index)")
        }
    }
}
