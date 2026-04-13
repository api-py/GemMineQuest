import SwiftUI

class ProgressManager: ObservableObject {
    @Published var progress: PlayerProgress
    @Published var didResetDueToCorruption = false

    private static let storageKey = "playerProgress"
    private static let checksumKey = "playerProgressChecksum"

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private static let isoFormatter = ISO8601DateFormatter()

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
            self.didResetDueToCorruption = true
        }
        self.progress = PlayerProgress()
    }

    func spendCoins(_ amount: Int) -> Bool {
        guard progress.coins >= amount else { return false }
        progress.addCoins(-amount)
        save()
        return true
    }

    func saveLevelResult(level: Int, stars: Int, score: Int, goldSpent: Int = 0) {
        progress.recordResult(level: level, stars: stars, score: score)
        progress.totalGamesPlayed += 1
        // Award coins based on stars earned + 50% refund of gold spent on extra moves
        let coinReward = stars * 25
        let refundBonus = (goldSpent > 0 && stars > 0) ? goldSpent / 2 : 0
        progress.addCoins(coinReward + refundBonus)
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
        #if DEBUG
        // God Mode: free purchases (debug builds only)
        if UserDefaults.standard.bool(forKey: "godModeEnabled") {
            for _ in 0..<item.quantity {
                boosterInventory.increment(item.boosterType)
            }
            save()
            return true
        }
        #endif
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
        guard let lastDate = Self.dateFormatter.date(from: lastDateStr) else { return true }
        return !Calendar.current.isDateInToday(lastDate)
    }

    func claimDailyReward() -> DailyReward {
        let todayStr = Self.dateFormatter.string(from: Date())

        // Update streak
        if let lastDateStr = progress.lastDailyRewardDate,
           let lastDate = Self.dateFormatter.date(from: lastDateStr) {
            if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()),
               Calendar.current.isDate(lastDate, inSameDayAs: yesterday) {
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
        guard let lastDate = Self.isoFormatter.date(from: lastSpinStr) else { return true }
        return !Calendar.current.isDateInToday(lastDate)
    }

    func recordSpin() {
        progress.lastSpinDate = Self.isoFormatter.string(from: Date())
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
        guard let data = try? JSONEncoder().encode(progress) else {
            print("[ProgressManager] Failed to encode progress")
            return
        }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
        UserDefaults.standard.set(Self.checksum(for: data), forKey: Self.checksumKey)
    }

    private static func checksum(for data: Data) -> String {
        ChecksumUtility.hmac(for: data, salt: "GemMineQuest.progress.salt.v1")
    }
}
