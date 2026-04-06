import SwiftUI
import CryptoKit

class ProgressManager: ObservableObject {
    @Published var progress: PlayerProgress

    private static let storageKey = "playerProgress"
    private static let checksumKey = "playerProgressChecksum"

    init() {
        if let data = UserDefaults.standard.data(forKey: Self.storageKey) {
            let storedChecksum = UserDefaults.standard.string(forKey: Self.checksumKey)
            let computedChecksum = Self.checksum(for: data)

            if storedChecksum == computedChecksum {
                do {
                    let decoded = try JSONDecoder().decode(PlayerProgress.self, from: data)
                    self.progress = decoded
                    return
                } catch {
                    print("[ProgressManager] Decode error: \(error.localizedDescription)")
                }
            } else {
                print("[ProgressManager] Data integrity check failed — resetting to defaults")
            }
        }
        self.progress = PlayerProgress()
    }

    func saveLevelResult(level: Int, stars: Int, score: Int) {
        progress.recordResult(level: level, stars: stars, score: score)
        progress.totalGamesPlayed += 1
        // Award coins based on stars earned
        let coinReward = stars * 25
        progress.addCoins(coinReward)
        // Reset consecutive loss counter on win
        if stars > 0 {
            progress.consecutiveLosses[level] = 0
        }
        save()
    }

    /// Record a loss on a level. Returns a booster type if one was awarded (every 10 consecutive losses).
    func recordLevelLoss(level: Int, boosterInventory: BoosterInventory) -> BoosterType? {
        progress.totalGamesPlayed += 1
        progress.consecutiveLosses[level, default: 0] += 1
        let count = progress.consecutiveLosses[level] ?? 0
        save()

        guard count > 0, count % 10 == 0 else { return nil }

        let inGameBoosters: [BoosterType] = [.pickaxe, .dynamite, .droneStrike, .gemForge, .mineCartRush]
        let awarded = inGameBoosters.randomElement() ?? .pickaxe
        boosterInventory.increment(awarded)
        return awarded
    }

    func isLevelUnlocked(_ level: Int) -> Bool {
        progress.isUnlocked(level)
    }

    func resetProgress() {
        progress = PlayerProgress()
        save()
    }

    // MARK: - Shop

    func purchaseShopItem(_ item: ShopItem, boosterInventory: BoosterInventory) -> Bool {
        // God Mode: free purchases
        if UserDefaults.standard.bool(forKey: "godModeEnabled") {
            for _ in 0..<item.quantity {
                boosterInventory.increment(item.boosterType)
            }
            save()
            return true
        }
        guard progress.coins >= item.price else { return false }
        progress.addCoins(-item.price)
        for _ in 0..<item.quantity {
            boosterInventory.increment(item.boosterType)
        }
        save()
        return true
    }

    // MARK: - Daily Reward

    struct DailyReward {
        let day: Int
        let boosterType: BoosterType?
        let coinAmount: Int
        let gemAmount: Int
    }

    func hasDailyReward() -> Bool {
        guard let lastDateStr = progress.lastDailyRewardDate else { return true }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let lastDate = formatter.date(from: lastDateStr) else { return true }
        return !Calendar.current.isDateInToday(lastDate)
    }

    func claimDailyReward() -> DailyReward {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.string(from: Date())

        // Update streak
        if let lastDateStr = progress.lastDailyRewardDate,
           let lastDate = formatter.date(from: lastDateStr) {
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            if Calendar.current.isDate(lastDate, inSameDayAs: yesterday) {
                progress.dailyStreak = (progress.dailyStreak % 7) + 1
            } else {
                progress.dailyStreak = 1
            }
        } else {
            progress.dailyStreak = 1
        }

        progress.lastDailyRewardDate = todayStr

        let day = progress.dailyStreak
        let coinAmount: Int
        let gemAmount: Int
        let boosterType: BoosterType?

        switch day {
        case 1: coinAmount = 50;  gemAmount = 0; boosterType = nil
        case 2: coinAmount = 75;  gemAmount = 0; boosterType = .pickaxe
        case 3: coinAmount = 100; gemAmount = 1; boosterType = nil
        case 4: coinAmount = 100; gemAmount = 0; boosterType = .dynamite
        case 5: coinAmount = 150; gemAmount = 2; boosterType = nil
        case 6: coinAmount = 200; gemAmount = 0; boosterType = .droneStrike
        case 7: coinAmount = 300; gemAmount = 5; boosterType = .gemForge
        default: coinAmount = 50; gemAmount = 0; boosterType = nil
        }

        progress.addCoins(coinAmount)
        progress.gems += gemAmount
        save()

        return DailyReward(day: day, boosterType: boosterType, coinAmount: coinAmount, gemAmount: gemAmount)
    }

    // MARK: - Spin Wheel

    func hasFreeSpin() -> Bool {
        guard let lastSpinStr = progress.lastSpinDate else { return true }
        let formatter = ISO8601DateFormatter()
        guard let lastDate = formatter.date(from: lastSpinStr) else { return true }
        return !Calendar.current.isDateInToday(lastDate)
    }

    func recordSpin() {
        let formatter = ISO8601DateFormatter()
        progress.lastSpinDate = formatter.string(from: Date())
        save()
    }

    // MARK: - Achievements

    func checkAchievements() -> [Achievement] {
        var newlyUnlocked: [Achievement] = []
        for achievement in Achievement.allCases {
            if achievement.isUnlocked(progress: progress)
                && !progress.unlockedAchievements.contains(achievement.rawValue) {
                progress.unlockedAchievements.append(achievement.rawValue)
                progress.addCoins(achievement.coinReward)
                newlyUnlocked.append(achievement)
            }
        }
        if !newlyUnlocked.isEmpty {
            save()
        }
        return newlyUnlocked
    }

    // MARK: - Milestones

    func checkMilestones() -> [String] {
        var newMilestones: [String] = []
        let milestoneThresholds = [10, 25, 50, 100, 200, 500]

        for threshold in milestoneThresholds {
            let id = "levels_\(threshold)"
            if progress.levelsCompleted >= threshold && !progress.claimedMilestones.contains(id) {
                newMilestones.append(id)
            }
        }

        let starThresholds = [50, 100, 250, 500]
        for threshold in starThresholds {
            let id = "stars_\(threshold)"
            if progress.totalStars >= threshold && !progress.claimedMilestones.contains(id) {
                newMilestones.append(id)
            }
        }

        return newMilestones
    }

    func claimMilestone(_ id: String) {
        guard !progress.claimedMilestones.contains(id) else { return }
        progress.claimedMilestones.append(id)
        progress.addCoins(200)
        progress.gems += 3
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(progress) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
        UserDefaults.standard.set(Self.checksum(for: data), forKey: Self.checksumKey)
    }

    private static func checksum(for data: Data) -> String {
        let key = SymmetricKey(data: Data("GemMineQuest.progress.salt.v1".utf8))
        let mac = HMAC<SHA256>.authenticationCode(for: data, using: key)
        return Data(mac).base64EncodedString()
    }
}
