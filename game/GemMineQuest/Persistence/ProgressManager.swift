import SwiftUI

class ProgressManager: ObservableObject {
    @Published var progress: PlayerProgress

    private static let storageKey = "playerProgress"

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
        save()
    }

    func isLevelUnlocked(_ level: Int) -> Bool {
        progress.isUnlocked(level)
    }

    func resetProgress() {
        progress = PlayerProgress()
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }
}
