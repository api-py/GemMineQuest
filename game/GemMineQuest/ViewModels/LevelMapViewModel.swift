import SwiftUI

struct LevelMapItem: Identifiable {
    let id: Int
    let number: Int
    let isUnlocked: Bool
    let stars: Int
    let highScore: Int
}

class LevelMapViewModel: ObservableObject {
    @Published var levels: [LevelMapItem] = []
    let progressManager: ProgressManager

    private let displayCount = 100  // Show 100 levels on the map

    init(progressManager: ProgressManager) {
        self.progressManager = progressManager
        refreshLevels()
    }

    func refreshLevels() {
        let maxLevel = max(progressManager.progress.highestUnlocked + 10, displayCount)
        levels = (1...maxLevel).map { num in
            LevelMapItem(
                id: num,
                number: num,
                isUnlocked: progressManager.isLevelUnlocked(num),
                stars: progressManager.progress.stars(for: num),
                highScore: progressManager.progress.highScore(for: num)
            )
        }
    }

    var currentLevel: Int {
        progressManager.progress.highestUnlocked
    }
}
