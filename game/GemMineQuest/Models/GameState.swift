import Foundation

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

    var godModeEnabled: Bool = false

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
        if score >= level.targetScores[2] { return 3 }
        if score >= level.targetScores[1] { return 2 }
        if score >= level.targetScores[0] { return 1 }
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
        if !godModeEnabled {
            movesRemaining = max(0, movesRemaining - 1)
        }
    }
}
