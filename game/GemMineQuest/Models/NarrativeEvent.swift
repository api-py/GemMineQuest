import Foundation

/// Story beats tied to zone transitions and key milestones in the Welsh mining quest.
struct NarrativeEvent {
    let triggerLevel: Int
    let characterKey: String  // "coblynau" or "dragon"
    let dialogueKey: String   // localization key for the dialogue text
    let isZoneIntro: Bool

    /// All narrative events in the game, ordered by trigger level.
    static let allEvents: [NarrativeEvent] = [
        // Zone 1: Great Orme — Coblynau introduction
        NarrativeEvent(triggerLevel: 1, characterKey: "coblynau", dialogueKey: "zone.1.narrative", isZoneIntro: true),
        // Zone 2: South Wales Coalfields
        NarrativeEvent(triggerLevel: 31, characterKey: "coblynau", dialogueKey: "zone.2.narrative", isZoneIntro: true),
        // Zone 3: Parys Mountain
        NarrativeEvent(triggerLevel: 61, characterKey: "coblynau", dialogueKey: "zone.3.narrative", isZoneIntro: true),
        // Zone 4: Llechwedd Slate
        NarrativeEvent(triggerLevel: 91, characterKey: "coblynau", dialogueKey: "zone.4.narrative", isZoneIntro: true),
        // Zone 5: Dolgellau Gold Belt
        NarrativeEvent(triggerLevel: 121, characterKey: "coblynau", dialogueKey: "zone.5.narrative", isZoneIntro: true),
        // Zone 6: Dolaucothi Roman Mines
        NarrativeEvent(triggerLevel: 151, characterKey: "coblynau", dialogueKey: "zone.6.narrative", isZoneIntro: true),
        // Zone 7: Dinas Emrys — Dragon's lair
        NarrativeEvent(triggerLevel: 181, characterKey: "dragon", dialogueKey: "zone.7.narrative", isZoneIntro: true),
    ]

    /// Returns the narrative event for a given level, if any.
    static func event(for level: Int) -> NarrativeEvent? {
        return allEvents.first(where: { $0.triggerLevel == level })
    }

    /// Returns the most recent zone intro event at or before the given level.
    static func currentZoneEvent(for level: Int) -> NarrativeEvent? {
        return allEvents.last(where: { $0.triggerLevel <= level && $0.isZoneIntro })
    }
}
