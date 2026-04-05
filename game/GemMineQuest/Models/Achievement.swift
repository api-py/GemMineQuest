import Foundation

enum Achievement: String, CaseIterable, Codable {
    case firstDig           // Complete level 1
    case apprenticeMiner    // Complete 10 levels
    case journeymanMiner    // Complete 25 levels
    case masterMiner        // Complete 50 levels
    case perfectVein        // Get 3 stars on any level
    case goldRush           // Collect 50 gold gems total
    case silverStrike       // Collect 50 silver gems total
    case chainReaction      // Get a 5x chain combo
    case explosiveExpert    // Use 10 volatile gems
    case laserFocus         // Use 20 laser gems
    case streakMaster       // 7-day login streak
    case bigSpender         // Spend 5000 coins total
    case centurion          // Complete 100 levels

    var displayName: String {
        switch self {
        case .firstDig: return "First Dig"
        case .apprenticeMiner: return "Apprentice Miner"
        case .journeymanMiner: return "Journeyman Miner"
        case .masterMiner: return "Master Miner"
        case .perfectVein: return "Perfect Vein"
        case .goldRush: return "Gold Rush"
        case .silverStrike: return "Silver Strike"
        case .chainReaction: return "Chain Reaction"
        case .explosiveExpert: return "Explosive Expert"
        case .laserFocus: return "Laser Focus"
        case .streakMaster: return "Streak Master"
        case .bigSpender: return "Big Spender"
        case .centurion: return "Centurion"
        }
    }

    var description: String {
        switch self {
        case .firstDig: return "Complete your first level"
        case .apprenticeMiner: return "Complete 10 levels"
        case .journeymanMiner: return "Complete 25 levels"
        case .masterMiner: return "Complete 50 levels"
        case .perfectVein: return "Get 3 stars on any level"
        case .goldRush: return "Collect 50 gold nuggets"
        case .silverStrike: return "Collect 50 silver ore"
        case .chainReaction: return "Get a 5x chain combo"
        case .explosiveExpert: return "Use 10 volatile gems"
        case .laserFocus: return "Use 20 laser gems"
        case .streakMaster: return "Maintain a 7-day login streak"
        case .bigSpender: return "Spend 5,000 coins total"
        case .centurion: return "Complete 100 levels"
        }
    }

    var iconName: String {
        switch self {
        case .firstDig: return "hammer.fill"
        case .apprenticeMiner: return "pickaxe"
        case .journeymanMiner: return "mountain.2.fill"
        case .masterMiner: return "crown.fill"
        case .perfectVein: return "star.fill"
        case .goldRush: return "bitcoinsign.circle.fill"
        case .silverStrike: return "moonphase.waning.crescent"
        case .chainReaction: return "link"
        case .explosiveExpert: return "flame.fill"
        case .laserFocus: return "bolt.fill"
        case .streakMaster: return "calendar.badge.checkmark"
        case .bigSpender: return "bag.fill"
        case .centurion: return "shield.checkered"
        }
    }

    var coinReward: Int {
        switch self {
        case .firstDig: return 50
        case .apprenticeMiner: return 200
        case .journeymanMiner: return 500
        case .masterMiner: return 1000
        case .perfectVein: return 100
        case .goldRush: return 300
        case .silverStrike: return 300
        case .chainReaction: return 200
        case .explosiveExpert: return 150
        case .laserFocus: return 150
        case .streakMaster: return 500
        case .bigSpender: return 250
        case .centurion: return 2000
        }
    }

    func isUnlocked(progress: PlayerProgress) -> Bool {
        switch self {
        case .firstDig:
            return progress.levelsCompleted >= 1
        case .apprenticeMiner:
            return progress.levelsCompleted >= 10
        case .journeymanMiner:
            return progress.levelsCompleted >= 25
        case .masterMiner:
            return progress.levelsCompleted >= 50
        case .perfectVein:
            return progress.levelStars.values.contains(where: { $0 >= 3 })
        case .goldRush:
            return (progress.totalGemsCollected["1"] ?? 0) >= 50  // gold = rawValue 1
        case .silverStrike:
            return (progress.totalGemsCollected["5"] ?? 0) >= 50  // silver = rawValue 5
        case .chainReaction:
            return progress.bestChainCombo >= 5
        case .explosiveExpert:
            return (progress.totalSpecialsUsed["volatile"] ?? 0) >= 10
        case .laserFocus:
            return (progress.totalSpecialsUsed["laser"] ?? 0) >= 20
        case .streakMaster:
            return progress.dailyStreak >= 7
        case .bigSpender:
            return progress.totalCoinsSpent >= 5000
        case .centurion:
            return progress.levelsCompleted >= 100
        }
    }
}
