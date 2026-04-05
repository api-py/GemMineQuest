import SwiftUI
import CryptoKit

class BoosterInventory: ObservableObject {
    @Published var counts: [BoosterType: Int]

    private static let storageKey = "boosterInventory"
    private static let checksumKey = "boosterInventoryChecksum"
    private static let lastDailyRewardKey = "lastDailyRewardDate"
    private static let initialCount = 4
    private static let maxBoosterCount = 999

    init() {
        if let data = UserDefaults.standard.data(forKey: Self.storageKey) {
            let storedChecksum = UserDefaults.standard.string(forKey: Self.checksumKey)
            let computedChecksum = Self.checksum(for: data)

            if storedChecksum == computedChecksum,
               let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
                var restored: [BoosterType: Int] = [:]
                for (key, value) in decoded {
                    if let type = BoosterType(rawValue: key) {
                        restored[type] = min(max(value, 0), Self.maxBoosterCount)
                    }
                }
                for type in Self.allInGameBoosters {
                    if restored[type] == nil {
                        restored[type] = Self.initialCount
                    }
                }
                self.counts = restored
                return
            } else {
                print("[BoosterInventory] Data integrity check failed — resetting to defaults")
            }
        }
        // First launch or integrity failure: give initial count of each
        var initial: [BoosterType: Int] = [:]
        for type in Self.allInGameBoosters {
            initial[type] = Self.initialCount
        }
        self.counts = initial
        save()
    }

    static let allInGameBoosters: [BoosterType] = [.pickaxe, .dynamite, .gemForge, .swapCharge, .droneStrike, .mineCartRush]

    var godModeActive: Bool = false

    func count(for type: BoosterType) -> Int {
        counts[type] ?? 0
    }

    /// Use one booster. Returns true if successful. In God Mode, never decrements.
    func use(_ type: BoosterType) -> Bool {
        if godModeActive { return true }  // Infinite tools in God Mode
        guard let current = counts[type], current > 0 else { return false }
        counts[type] = current - 1
        save()
        return true
    }

    /// Award boosters for reaching a level milestone (every 25 levels)
    func awardMilestone() {
        for type in Self.allInGameBoosters {
            let current = counts[type, default: 0]
            counts[type] = min(current + 1, Self.maxBoosterCount)
        }
        save()
    }

    /// Check if a level milestone was reached and award if so
    func checkMilestoneReward(levelCompleted: Int) {
        // 3x pickaxe every 25 levels (25, 50, 75, 100, ...)
        if levelCompleted > 0 && levelCompleted % 25 == 0 {
            let current = counts[.pickaxe, default: 0]
            counts[.pickaxe] = min(current + 3, Self.maxBoosterCount)
        }

        // 1x dynamite every 50 levels (50, 100, 150, ...)
        if levelCompleted > 0 && levelCompleted % 50 == 0 {
            let current = counts[.dynamite, default: 0]
            counts[.dynamite] = min(current + 1, Self.maxBoosterCount)
        }

        save()
    }

    /// Check star-based rewards: 3x drone every 10 three-star levels
    func checkStarRewards(totalThreeStarLevels: Int) {
        let storageKey = "lastDroneStarRewardCount"
        let lastRewarded = UserDefaults.standard.integer(forKey: storageKey)
        let milestonesReached = totalThreeStarLevels / 10
        let lastMilestones = lastRewarded / 10

        if milestonesReached > lastMilestones {
            let newMilestones = milestonesReached - lastMilestones
            let reward = min(newMilestones * 3, Self.maxBoosterCount)
            let current = counts[.droneStrike, default: 0]
            counts[.droneStrike] = min(current + reward, Self.maxBoosterCount)
            UserDefaults.standard.set(milestonesReached * 10, forKey: storageKey)
            save()
        }
    }

    /// Award daily login bonus: +1 of each booster if a new calendar day since last reward.
    /// Call this when the game starts (app launch / entering game screen).
    /// Only awards once per calendar day — not retroactive for missed days.
    @discardableResult
    func claimDailyRewardIfNeeded() -> Bool {
        let now = Date()
        let today = Calendar.current.startOfDay(for: now)
        let lastDate = UserDefaults.standard.object(forKey: Self.lastDailyRewardKey) as? Date

        if let last = lastDate {
            // Reject if last claim is in the future (clock manipulation)
            if last > now { return false }
            if Calendar.current.isDate(last, inSameDayAs: today) {
                return false // Already claimed today
            }
        }

        // Award +1 of each booster
        for type in Self.allInGameBoosters {
            let current = counts[type, default: 0]
            counts[type] = min(current + 1, Self.maxBoosterCount)
        }
        UserDefaults.standard.set(today, forKey: Self.lastDailyRewardKey)
        save()
        return true
    }

    func increment(_ type: BoosterType) {
        let current = counts[type, default: 0]
        guard current < Self.maxBoosterCount else { return }
        counts[type] = current + 1
        save()
    }

    func decrement(_ type: BoosterType) {
        guard let current = counts[type], current > 0 else { return }
        counts[type] = current - 1
        save()
    }

    func reset() {
        var initial: [BoosterType: Int] = [:]
        for type in Self.allInGameBoosters {
            initial[type] = Self.initialCount
        }
        self.counts = initial
        save()
    }

    private func save() {
        var encoded: [String: Int] = [:]
        for (key, value) in counts {
            encoded[key.rawValue] = min(value, Self.maxBoosterCount)
        }
        guard let data = try? JSONEncoder().encode(encoded) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
        UserDefaults.standard.set(Self.checksum(for: data), forKey: Self.checksumKey)
    }

    private static func checksum(for data: Data) -> String {
        let key = SymmetricKey(data: Data("GemMineQuest.boosters.salt.v1".utf8))
        let mac = HMAC<SHA256>.authenticationCode(for: data, using: key)
        return Data(mac).base64EncodedString()
    }
}
