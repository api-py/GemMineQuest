import SwiftUI

class ProgressManager: ObservableObject {
    @Published var progress: PlayerProgress

    private static let storageKey = "playerProgress"

    private static var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    init() {
        if let data = UserDefaults.standard.data(forKey: Self.storageKey),
           let decoded = try? JSONDecoder().decode(PlayerProgress.self, from: data) {
            self.progress = decoded
        } else {
            self.progress = PlayerProgress()
        }
    }

    func saveLevelResult(level: Int, stars: Int, score: Int) {
        progress.recordResult(level: level, stars: stars, score: score)

        // Award coins based on score
        let coinsEarned = 50 + score / 100
        let bonus = stars == 3 ? 100 : 0
        progress.addCoins(coinsEarned + bonus)

        save()
    }

    func isLevelUnlocked(_ level: Int) -> Bool {
        progress.isUnlocked(level)
    }

    func resetProgress() {
        progress = PlayerProgress()
        save()
    }

    // MARK: - Daily Reward

    func hasDailyReward() -> Bool {
        progress.lastDailyRewardDate != Self.todayString
    }

    struct DailyReward {
        let day: Int          // 1-7
        let boosterType: String?
        let boosterCount: Int
        let coinAmount: Int
        let gemAmount: Int
    }

    func claimDailyReward() -> DailyReward {
        let today = Self.todayString

        // Check if streak is broken (more than 1 day gap)
        if let lastDate = progress.lastDailyRewardDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if let last = formatter.date(from: lastDate),
               let diff = Calendar.current.dateComponents([.day], from: last, to: Date()).day,
               diff > 1 {
                progress.dailyStreak = 0  // Reset streak
            }
        }

        progress.dailyStreak = (progress.dailyStreak % 7) + 1
        progress.lastDailyRewardDate = today

        let reward = dailyRewardFor(day: progress.dailyStreak)

        if let booster = reward.boosterType {
            progress.addBooster(booster, count: reward.boosterCount)
        }
        if reward.coinAmount > 0 {
            progress.addCoins(reward.coinAmount)
        }
        progress.gems += reward.gemAmount

        save()
        return reward
    }

    private func dailyRewardFor(day: Int) -> DailyReward {
        switch day {
        case 1: return DailyReward(day: 1, boosterType: "pickaxe", boosterCount: 1, coinAmount: 0, gemAmount: 0)
        case 2: return DailyReward(day: 2, boosterType: "pickaxe", boosterCount: 1, coinAmount: 0, gemAmount: 0)
        case 3: return DailyReward(day: 3, boosterType: nil, boosterCount: 0, coinAmount: 500, gemAmount: 0)
        case 4: return DailyReward(day: 4, boosterType: "drone", boosterCount: 1, coinAmount: 0, gemAmount: 0)
        case 5: return DailyReward(day: 5, boosterType: nil, boosterCount: 0, coinAmount: 1000, gemAmount: 0)
        case 6: return DailyReward(day: 6, boosterType: "cart", boosterCount: 2, coinAmount: 0, gemAmount: 0)
        case 7: return DailyReward(day: 7, boosterType: nil, boosterCount: 0, coinAmount: 0, gemAmount: 3)
        default: return DailyReward(day: 1, boosterType: "pickaxe", boosterCount: 1, coinAmount: 0, gemAmount: 0)
        }
    }

    // MARK: - Spin Wheel

    func hasFreeSpin() -> Bool {
        progress.lastSpinDate != Self.todayString
    }

    func recordSpin() {
        progress.lastSpinDate = Self.todayString
        save()
    }

    // MARK: - Boosters

    func useBooster(_ type: String) -> Bool {
        let result = progress.useBooster(type)
        if result { save() }
        return result
    }

    func addBooster(_ type: String, count: Int = 1) {
        progress.addBooster(type, count: count)
        save()
    }

    func addCoins(_ amount: Int) {
        progress.addCoins(amount)
        save()
    }

    // MARK: - Achievements

    func unlockAchievement(_ id: String) -> Bool {
        guard !progress.unlockedAchievements.contains(id) else { return false }
        progress.unlockedAchievements.append(id)
        save()
        return true
    }

    func checkAchievements() -> [Achievement] {
        var newlyUnlocked: [Achievement] = []

        for achievement in Achievement.allCases {
            guard !progress.unlockedAchievements.contains(achievement.rawValue) else { continue }
            if achievement.isUnlocked(progress: progress) {
                progress.unlockedAchievements.append(achievement.rawValue)
                progress.addCoins(achievement.coinReward)
                newlyUnlocked.append(achievement)
            }
        }

        if !newlyUnlocked.isEmpty { save() }
        return newlyUnlocked
    }

    // MARK: - Milestones

    func checkMilestones() -> [String] {
        var triggered: [String] = []

        let milestones: [(String, () -> Bool)] = [
            ("first_3star", { self.progress.levelStars.values.contains(where: { $0 == 3 }) }),
            ("10_levels", { self.progress.levelsCompleted >= 10 }),
            ("25_stars", { self.progress.totalStars >= 25 }),
            ("50_stars", { self.progress.totalStars >= 50 }),
            ("100_stars", { self.progress.totalStars >= 100 }),
            ("20_levels", { self.progress.levelsCompleted >= 20 }),
            ("50_levels", { self.progress.levelsCompleted >= 50 }),
        ]

        for (id, check) in milestones {
            if !progress.claimedMilestones.contains(id) && check() {
                triggered.append(id)
            }
        }

        return triggered
    }

    func claimMilestone(_ id: String) {
        progress.claimedMilestones.append(id)

        // Milestone rewards
        switch id {
        case "first_3star": progress.addCoins(100)
        case "10_levels": progress.addCoins(300)
        case "25_stars": progress.addBooster("pickaxe", count: 2)
        case "50_stars": progress.addBooster("drone", count: 2)
        case "100_stars": progress.gems += 5
        case "20_levels": progress.addCoins(500)
        case "50_levels": progress.gems += 10
        default: break
        }

        save()
    }

    // MARK: - Persistence

    private func save() {
        if let data = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }
}
