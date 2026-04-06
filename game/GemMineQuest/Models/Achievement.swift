import Foundation

enum Achievement: String, CaseIterable {
    case firstDig
    case apprenticeMiner
    case journeymanMiner
    case masterMiner
    case legendaryMiner
    case starCollector
    case starHoarder
    case perfectRun
    case comboKing
    case explosionExpert
    case gemHunter
    case dailyDevotion
    case fortuneSeeker

    var displayName: String {
        switch self {
        case .firstDig: return "First Dig"
        case .apprenticeMiner: return "Apprentice Miner"
        case .journeymanMiner: return "Journeyman Miner"
        case .masterMiner: return "Master Miner"
        case .legendaryMiner: return "Legendary Miner"
        case .starCollector: return "Star Collector"
        case .starHoarder: return "Star Hoarder"
        case .perfectRun: return "Perfect Run"
        case .comboKing: return "Combo King"
        case .explosionExpert: return "Explosion Expert"
        case .gemHunter: return "Gem Hunter"
        case .dailyDevotion: return "Daily Devotion"
        case .fortuneSeeker: return "Fortune Seeker"
        }
    }

    var description: String {
        switch self {
        case .firstDig: return "Complete your first level"
        case .apprenticeMiner: return "Complete 10 levels"
        case .journeymanMiner: return "Complete 25 levels"
        case .masterMiner: return "Complete 50 levels"
        case .legendaryMiner: return "Complete 100 levels"
        case .starCollector: return "Earn 50 total stars"
        case .starHoarder: return "Earn 200 total stars"
        case .perfectRun: return "Earn 3 stars on any level"
        case .comboKing: return "Complete 5 levels in a row"
        case .explosionExpert: return "Use 10 dynamite boosters"
        case .gemHunter: return "Collect 500 gems total"
        case .dailyDevotion: return "Claim 7 daily rewards in a row"
        case .fortuneSeeker: return "Spin the wheel 10 times"
        }
    }

    var iconName: String {
        switch self {
        case .firstDig: return "hammer.fill"
        case .apprenticeMiner: return "hammer.circle.fill"
        case .journeymanMiner: return "figure.walk"
        case .masterMiner: return "crown.fill"
        case .legendaryMiner: return "star.circle.fill"
        case .starCollector: return "star.fill"
        case .starHoarder: return "sparkles"
        case .perfectRun: return "rosette"
        case .comboKing: return "bolt.fill"
        case .explosionExpert: return "flame.fill"
        case .gemHunter: return "diamond.fill"
        case .dailyDevotion: return "calendar.badge.checkmark"
        case .fortuneSeeker: return "arrow.triangle.2.circlepath"
        }
    }

    var coinReward: Int {
        switch self {
        case .firstDig: return 50
        case .apprenticeMiner: return 100
        case .journeymanMiner: return 200
        case .masterMiner: return 500
        case .legendaryMiner: return 1000
        case .starCollector: return 150
        case .starHoarder: return 400
        case .perfectRun: return 75
        case .comboKing: return 200
        case .explosionExpert: return 150
        case .gemHunter: return 300
        case .dailyDevotion: return 250
        case .fortuneSeeker: return 100
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
        case .legendaryMiner:
            return progress.levelsCompleted >= 100
        case .starCollector:
            return progress.totalStars >= 50
        case .starHoarder:
            return progress.totalStars >= 200
        case .perfectRun:
            return progress.levelStars.values.contains(where: { $0 >= 3 })
        case .comboKing:
            let completed = progress.levelStars.filter { $0.value > 0 }.keys.sorted()
            guard completed.count >= 5 else { return false }
            for i in 0..<(completed.count - 4) {
                let slice = Array(completed[i..<(i + 5)])
                if let last = slice.last, let first = slice.first, last - first == 4 { return true }
            }
            return false
        case .explosionExpert:
            return progress.totalGamesPlayed >= 10
        case .gemHunter:
            return progress.gems >= 500
        case .dailyDevotion:
            return progress.dailyStreak >= 7
        case .fortuneSeeker:
            return progress.totalGamesPlayed >= 10
        }
    }
}
