import Foundation

struct PlayerProgress: Codable {
    // MARK: - Level Progress
    var levelStars: [Int: Int] = [:]     // level number -> stars (1-3)
    var highScores: [Int: Int] = [:]     // level number -> best score
    var highestUnlocked: Int = 1

    // MARK: - Booster Inventory
    var boosters: [String: Int] = [
        "pickaxe": 3,
        "swap": 2,
        "drone": 1,
        "cart": 1
    ]

    // MARK: - Currency
    var coins: Int = 100
    var gems: Int = 5  // Premium currency

    // MARK: - Daily Tracking
    var lastDailyRewardDate: String? = nil  // "yyyy-MM-dd"
    var dailyStreak: Int = 0
    var lastSpinDate: String? = nil         // "yyyy-MM-dd"
    var totalGamesPlayed: Int = 0

    // MARK: - Achievements
    var unlockedAchievements: [String] = []
    var totalGemsCollected: [String: Int] = [:]  // gemColor rawValue -> count
    var totalSpecialsUsed: [String: Int] = [:]   // specialType -> count
    var bestChainCombo: Int = 0
    var totalCoinsSpent: Int = 0

    // MARK: - Milestones
    var claimedMilestones: [String] = []

    // MARK: - Computed Properties

    func isUnlocked(_ level: Int) -> Bool {
        level <= highestUnlocked
    }

    func stars(for level: Int) -> Int {
        levelStars[level] ?? 0
    }

    func highScore(for level: Int) -> Int {
        highScores[level] ?? 0
    }

    var totalStars: Int {
        levelStars.values.reduce(0, +)
    }

    var levelsCompleted: Int {
        levelStars.count
    }

    mutating func recordResult(level: Int, stars: Int, score: Int) {
        if stars > (levelStars[level] ?? 0) {
            levelStars[level] = stars
        }
        if score > (highScores[level] ?? 0) {
            highScores[level] = score
        }
        if stars > 0 && level >= highestUnlocked {
            highestUnlocked = level + 1
        }
        totalGamesPlayed += 1
    }

    // MARK: - Booster Management

    func boosterCount(for type: String) -> Int {
        boosters[type] ?? 0
    }

    mutating func useBooster(_ type: String) -> Bool {
        guard (boosters[type] ?? 0) > 0 else { return false }
        boosters[type] = (boosters[type] ?? 0) - 1
        return true
    }

    mutating func addBooster(_ type: String, count: Int = 1) {
        boosters[type] = (boosters[type] ?? 0) + count
    }

    mutating func addCoins(_ amount: Int) {
        coins += amount
    }

    mutating func spendCoins(_ amount: Int) -> Bool {
        guard coins >= amount else { return false }
        coins -= amount
        totalCoinsSpent += amount
        return true
    }
}
