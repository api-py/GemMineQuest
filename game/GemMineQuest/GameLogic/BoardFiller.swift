import Foundation

class BoardFiller {

    private let matchDetector = MatchDetector()

    /// Drop existing gems down to fill gaps, then add new gems at top.
    /// Returns (fallMoves, newGems) for animation.
    func dropAndFill(board: Board, numColors: Int = 6) -> (falls: [(from: GridPosition, to: GridPosition)],
                                                             newGems: [(gem: Gem, at: GridPosition)]) {
        var falls: [(from: GridPosition, to: GridPosition)] = []
        var newGems: [(gem: Gem, at: GridPosition)] = []

        let colors = Array(GemColor.allCases.prefix(numColors))

        // Process each column
        for col in 0..<board.numColumns {
            // Drop existing gems down
            var writeRow = -1

            // Find lowest empty playable row
            for row in 0..<board.numRows {
                let pos = GridPosition(row: row, column: col)
                if !board.isPlayable(pos) { continue }
                if board.hasBlocker(at: pos) {
                    if case .boulder = board.blockerAt(pos) { continue }
                }

                if board[pos] == nil {
                    if writeRow == -1 { writeRow = row }
                } else if writeRow != -1 {
                    // Move this gem down to writeRow
                    let from = pos
                    let to = GridPosition(row: writeRow, column: col)
                    if let gem = board[from] {
                        board.removeGem(at: from)
                        board.setGem(gem, at: to)
                        falls.append((from: from, to: to))
                    }
                    // Find next empty row
                    writeRow += 1
                    while writeRow < board.numRows {
                        let checkPos = GridPosition(row: writeRow, column: col)
                        if board.isPlayable(checkPos) && board[checkPos] == nil {
                            break
                        }
                        writeRow += 1
                    }
                }
            }

            // Fill remaining empty spaces with new gems from top
            for row in 0..<board.numRows {
                let pos = GridPosition(row: row, column: col)
                if board.isPlayable(pos) && board[pos] == nil && !board.hasBlocker(at: pos) {
                    let color = colors.randomElement()!
                    let gem = Gem(color: color, row: row, column: col)
                    board.setGem(gem, at: pos)
                    newGems.append((gem: gem, at: pos))
                }
            }
        }

        return (falls: falls, newGems: newGems)
    }

    /// Fill the board initially with no pre-existing matches.
    func initialFill(board: Board, numColors: Int = 6) {
        let colors = Array(GemColor.allCases.prefix(numColors))

        for row in 0..<board.numRows {
            for col in 0..<board.numColumns {
                let pos = GridPosition(row: row, column: col)
                guard board.isPlayable(pos) && !board.hasBlocker(at: pos) else { continue }
                // Skip positions that have boulders
                if case .boulder = board.blockerAt(pos) { continue }

                var color = colors.randomElement()!
                var attempts = 0

                // Ensure no 3-in-a-row with already placed gems
                while attempts < 20 {
                    if !createsMatchAt(board: board, row: row, col: col, color: color) {
                        break
                    }
                    color = colors.randomElement()!
                    attempts += 1
                }

                let gem = Gem(color: color, row: row, column: col)
                board.setGem(gem, at: pos)
            }
        }
    }

    /// Fill with seeded RNG for deterministic procedural levels
    func initialFill(board: Board, numColors: Int = 6, seed: UInt64) {
        var rng = SeededRandomNumberGenerator(seed: seed)
        let colors = Array(GemColor.allCases.prefix(numColors))

        for row in 0..<board.numRows {
            for col in 0..<board.numColumns {
                let pos = GridPosition(row: row, column: col)
                guard board.isPlayable(pos) && !board.hasBlocker(at: pos) else { continue }
                if case .boulder = board.blockerAt(pos) { continue }

                var color = colors.randomElement(using: &rng)!
                var attempts = 0

                while attempts < 20 {
                    if !createsMatchAt(board: board, row: row, col: col, color: color) {
                        break
                    }
                    color = colors.randomElement(using: &rng)!
                    attempts += 1
                }

                let gem = Gem(color: color, row: row, column: col)
                board.setGem(gem, at: pos)
            }
        }
    }

    /// Check if placing a gem at (row, col) with given color creates a 3-in-a-row
    private func createsMatchAt(board: Board, row: Int, col: Int, color: GemColor) -> Bool {
        // Check horizontal (left)
        if col >= 2 {
            if board[row, col - 1]?.color == color &&
               board[row, col - 2]?.color == color {
                return true
            }
        }

        // Check vertical (below)
        if row >= 2 {
            if board[row - 1, col]?.color == color &&
               board[row - 2, col]?.color == color {
                return true
            }
        }

        return false
    }

    /// Shuffle all gems on the board (for deadlock situations)
    func shuffle(board: Board) {
        var gems = board.allGems().filter { $0.special == .none }
        gems.shuffle()

        var gemIndex = 0
        for row in 0..<board.numRows {
            for col in 0..<board.numColumns {
                let pos = GridPosition(row: row, column: col)
                guard board.isPlayable(pos), let existing = board[pos], existing.special == .none else { continue }

                if gemIndex < gems.count {
                    var shuffled = gems[gemIndex]
                    shuffled.row = row
                    shuffled.column = col
                    board.setGem(shuffled, at: pos)
                    gemIndex += 1
                }
            }
        }
    }
}
