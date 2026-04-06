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
    let godMode: Bool

    private let displayCount = 500

    init(progressManager: ProgressManager, godMode: Bool = false) {
        self.progressManager = progressManager
        self.godMode = godMode
        refreshLevels()
    }

    func refreshLevels() {
        let maxLevel = max(progressManager.progress.highestUnlocked + 20, displayCount)
        levels = (1...maxLevel).map { num in
            LevelMapItem(
                id: num,
                number: num,
                isUnlocked: godMode || progressManager.isLevelUnlocked(num),
                stars: progressManager.progress.stars(for: num),
                highScore: progressManager.progress.highScore(for: num)
            )
        }
    }

    var currentLevel: Int {
        progressManager.progress.highestUnlocked
    }
}
