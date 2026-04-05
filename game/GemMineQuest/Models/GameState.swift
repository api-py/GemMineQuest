import Foundation

@MainActor
class GameState: ObservableObject {
    let level: Level
    let board: Board
    @Published var score: Int = 0
    @Published var movesRemaining: Int
    @Published var objectiveProgress: [String: Int] = [:]
    @Published var isComplete: Bool = false
    @Published var isFailed: Bool = false
    @Published var treasuresDropped: Int = 0
    @Published var oreCleared: Int = 0
    @Published var totalOre: Int = 0
    @Published var gemsCollected: [GemColor: Int] = [:]
    @Published var specialsCollected: [SpecialType: Int] = [:]
    @Published var movesMade: Int = 0

    var godModeEnabled: Bool = false

    /// Whether this level shuffles gems after every 3rd move
    var isShuffleLevel: Bool {
        // Every 5th level starting from 5: 5, 15, 25, 35, ...
        let n = level.number
        return n >= 5 && (n % 10 == 5)
    }

    init(level: Level, board: Board) {
        self.level = level
        self.board = board
        self.movesRemaining = level.maxMoves

        // Count total ore tiles
        var oreCount = 0
        for row in 0..<board.numRows {
            for col in 0..<board.numColumns {
                if board.tiles[row][col] == .oreVein { oreCount += 1 }
                if board.tiles[row][col] == .doubleOre { oreCount += 1 }
            }
        }
        self.totalOre = oreCount
    }

    var starRating: Int {
        let targets = level.targetScores
        if targets.count > 2, score >= targets[2] { return 3 }
        if targets.count > 1, score >= targets[1] { return 2 }
        if targets.count > 0, score >= targets[0] { return 1 }
        return 0
    }

    func checkObjectives() -> Bool {
        for objective in level.objectives {
            switch objective {
            case .reachScore(let target):
                if score < target { return false }
            case .clearAllOre:
                if oreCleared < totalOre { return false }
            case .dropTreasures(let count):
                if treasuresDropped < count { return false }
            case .collectGems(let color, let count):
                if (gemsCollected[color] ?? 0) < count { return false }
            case .collectSpecials(let type, let count):
                if (specialsCollected[type] ?? 0) < count { return false }
            }
        }
        return true
    }

    func decrementMoves() {
        movesMade += 1
        if !godModeEnabled {
            movesRemaining = max(0, movesRemaining - 1)
        }
    }
}
