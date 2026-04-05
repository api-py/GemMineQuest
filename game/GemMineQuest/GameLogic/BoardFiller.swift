import Foundation

/// Implements the two-phase gravity system:
/// 1. Vertical gravity (column compaction, blockers reset hole count)
/// 2. Diagonal fill (left-first bias, only for vertically-blocked cells)
/// 3. Loop until stable, then spawn new gems
class BoardFiller {

    // MARK: - Main Entry Point

    /// Drop existing gems, apply diagonal rolling, then spawn new gems.
    func dropAndFill(board: Board, numColors: Int = 6) -> (falls: [(from: GridPosition, to: GridPosition)],
                                                             newGems: [(gem: Gem, at: GridPosition)]) {
        var allFalls: [(from: GridPosition, to: GridPosition)] = []
        let colors = Array(GemColor.allCases.prefix(max(1, numColors)))

        // Phase 1+2: Loop vertical gravity + diagonal fill until stable
        var anyMoved = true
        while anyMoved {
            anyMoved = false

            let vFalls = applyVerticalGravity(board: board)
            if !vFalls.isEmpty { anyMoved = true; allFalls.append(contentsOf: vFalls) }

            let dFalls = applyDiagonalFill(board: board)
            if !dFalls.isEmpty { anyMoved = true; allFalls.append(contentsOf: dFalls) }
        }

        // Phase 3: Spawn new gems at the top of each column
        var newGems: [(gem: Gem, at: GridPosition)] = []
        for col in 0..<board.numColumns {
            for row in 0..<board.numRows {
                let pos = GridPosition(row: row, column: col)
                guard board.isPlayable(pos) && board[pos] == nil else { continue }
                guard !isBlockedPosition(board: board, pos: pos) else { continue }

                // Anti-match spawning: avoid creating instant 3-in-a-rows
                var color = colors.randomElement() ?? .ruby
                var attempts = 0
                while attempts < 30 && createsMatchAt(board: board, row: row, col: col, color: color) {
                    color = colors.randomElement() ?? .ruby
                    attempts += 1
                }
                let gem = Gem(color: color, row: row, column: col)
                board.setGem(gem, at: pos)
                newGems.append((gem: gem, at: pos))
            }
        }

        return (falls: allFalls, newGems: newGems)
    }

    // MARK: - Vertical Gravity (Hole-Counting)

    /// Each column independently: count holes from bottom, shift gems down.
    /// Immovable blockers reset the hole count.
    private func applyVerticalGravity(board: Board) -> [(from: GridPosition, to: GridPosition)] {
        var falls: [(from: GridPosition, to: GridPosition)] = []

        for col in 0..<board.numColumns {
            var holeCount = 0

            for row in 0..<board.numRows {  // row 0 = bottom
                let pos = GridPosition(row: row, column: col)

                if !board.isPlayable(pos) {
                    holeCount = 0  // Non-playable cell resets count
                    continue
                }

                if isImmovableBlocker(board: board, pos: pos) {
                    holeCount = 0  // Immovable blocker resets count
                    continue
                }

                if board[pos] == nil {
                    holeCount += 1
                } else if holeCount > 0 {
                    // Drop this gem down by holeCount rows
                    let targetRow = row - holeCount
                    guard targetRow >= 0 else { continue }
                    let targetPos = GridPosition(row: targetRow, column: col)
                    if let gem = board[pos] {
                        board.removeGem(at: pos)
                        board.setGem(gem, at: targetPos)
                        falls.append((from: pos, to: targetPos))
                    }
                }
            }
        }

        return falls
    }

    // MARK: - Diagonal Fill (Left-First Bias)

    /// For cells that can't be filled vertically, try diagonal rolling.
    /// Left-first bias: check upper-left before upper-right.
    private func applyDiagonalFill(board: Board) -> [(from: GridPosition, to: GridPosition)] {
        var falls: [(from: GridPosition, to: GridPosition)] = []
        var movedFrom = Set<GridPosition>()  // Prevent double-movement

        // Scan bottom-to-top, left-to-right
        for row in 0..<board.numRows {
            for col in 0..<board.numColumns {
                let pos = GridPosition(row: row, column: col)

                guard board.isPlayable(pos) else { continue }
                guard board[pos] == nil else { continue }
                guard cannotFillVertically(board: board, col: col, row: row) else { continue }

                // Try upper-left first (left bias)
                let upperLeft = GridPosition(row: row + 1, column: col - 1)
                if col > 0 && row + 1 < board.numRows
                   && board.isPlayable(upperLeft)
                   && board[upperLeft] != nil
                   && !isImmovableBlocker(board: board, pos: upperLeft)
                   && !movedFrom.contains(upperLeft) {
                    board.swapGems(upperLeft, pos)
                    falls.append((from: upperLeft, to: pos))
                    movedFrom.insert(pos)
                    continue
                }

                // Then try upper-right
                let upperRight = GridPosition(row: row + 1, column: col + 1)
                if col + 1 < board.numColumns && row + 1 < board.numRows
                   && board.isPlayable(upperRight)
                   && board[upperRight] != nil
                   && !isImmovableBlocker(board: board, pos: upperRight)
                   && !movedFrom.contains(upperRight) {
                    board.swapGems(upperRight, pos)
                    falls.append((from: upperRight, to: pos))
                    movedFrom.insert(pos)
                    continue
                }
            }
        }

        return falls
    }

    /// Returns true if the cell at (col, row) cannot be filled from above vertically.
    /// This means every cell above it in the same column is blocked/hole/non-playable.
    private func cannotFillVertically(board: Board, col: Int, row: Int) -> Bool {
        for r in (row + 1)..<board.numRows {
            let pos = GridPosition(row: r, column: col)
            if !board.isPlayable(pos) { continue }  // Hole — keep checking above
            if isImmovableBlocker(board: board, pos: pos) { continue }  // Blocked — keep checking

            // Found an empty space above (can receive spawned gem) or a movable piece
            return false
        }
        // Reached top through only blocked cells — vertical fill impossible
        return true
    }

    // MARK: - Helpers

    private func isImmovableBlocker(board: Board, pos: GridPosition) -> Bool {
        guard let blocker = board.blockerAt(pos) else { return false }
        switch blocker {
        case .boulder, .granite: return true
        default: return false
        }
    }

    private func isBlockedPosition(board: Board, pos: GridPosition) -> Bool {
        if let blocker = board.blockerAt(pos) {
            switch blocker {
            case .boulder: return true
            default: return false
            }
        }
        return false
    }

    // MARK: - Initial Fill

    /// Fill the board initially with no pre-existing matches.
    func initialFill(board: Board, numColors: Int = 6) {
        let colors = Array(GemColor.allCases.prefix(max(1, numColors)))

        for row in 0..<board.numRows {
            for col in 0..<board.numColumns {
                let pos = GridPosition(row: row, column: col)
                guard board.isPlayable(pos) else { continue }
                guard !isBlockedPosition(board: board, pos: pos) else { continue }

                var color = colors.randomElement() ?? .ruby
                var attempts = 0
                while attempts < 30 {
                    if !createsMatchAt(board: board, row: row, col: col, color: color) { break }
                    color = colors.randomElement() ?? .ruby
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
        let colors = Array(GemColor.allCases.prefix(max(1, numColors)))

        for row in 0..<board.numRows {
            for col in 0..<board.numColumns {
                let pos = GridPosition(row: row, column: col)
                guard board.isPlayable(pos) else { continue }
                guard !isBlockedPosition(board: board, pos: pos) else { continue }

                var color = colors.randomElement(using: &rng) ?? .ruby
                var attempts = 0
                while attempts < 30 {
                    if !createsMatchAt(board: board, row: row, col: col, color: color) { break }
                    color = colors.randomElement(using: &rng) ?? .ruby
                    attempts += 1
                }

                let gem = Gem(color: color, row: row, column: col)
                board.setGem(gem, at: pos)
            }
        }
    }

    private func createsMatchAt(board: Board, row: Int, col: Int, color: GemColor) -> Bool {
        // Existing horizontal check
        if col >= 2 {
            if board[row, col - 1]?.color == color && board[row, col - 2]?.color == color { return true }
        }
        // Existing vertical check
        if row >= 2 {
            if board[row - 1, col]?.color == color && board[row - 2, col]?.color == color { return true }
        }
        // Gap pattern check — [color, ?, color] vertically
        if row >= 1 && row + 1 < board.numRows {
            if board[row - 1, col]?.color == color && board[row + 1, col]?.color == color { return true }
        }
        // Gap pattern check — [color, ?, color] horizontally
        if col >= 1 && col + 1 < board.numColumns {
            if board[row, col - 1]?.color == color && board[row, col + 1]?.color == color { return true }
        }
        return false
    }

    /// Shuffle all non-special gems (for deadlock situations)
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
