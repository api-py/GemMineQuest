import Foundation

class MatchDetector {

    /// Detect all matches on the board. Returns an array of MatchResults.
    func detectMatches(on board: Board) -> [MatchResult] {
        let horizontalRuns = findHorizontalRuns(on: board)
        let verticalRuns = findVerticalRuns(on: board)
        let squareMatches = findSquareMatches(on: board)

        // Merge overlapping runs into combined shapes (L, T)
        let mergedMatches = mergeRuns(horizontal: horizontalRuns, vertical: verticalRuns, board: board)

        return mergedMatches + squareMatches
    }

    /// Check if a specific swap would produce any match
    func wouldMatch(board: Board, swapping posA: GridPosition, with posB: GridPosition) -> Bool {
        board.swapGems(posA, posB)
        let matches = detectMatches(on: board)
        board.swapGems(posA, posB) // swap back
        return !matches.isEmpty
    }

    /// Check if any valid swap exists on the board
    func hasAnyValidMove(on board: Board) -> Bool {
        for row in 0..<board.numRows {
            for col in 0..<board.numColumns {
                let pos = GridPosition(row: row, column: col)
                guard board[pos] != nil, board.isPlayable(pos) else { continue }

                // Check right neighbor
                let right = GridPosition(row: row, column: col + 1)
                if board.isValidPosition(right) && board[right] != nil && board.isPlayable(right) {
                    if wouldMatch(board: board, swapping: pos, with: right) {
                        return true
                    }
                }

                // Check upper neighbor
                let up = GridPosition(row: row + 1, column: col)
                if board.isValidPosition(up) && board[up] != nil && board.isPlayable(up) {
                    if wouldMatch(board: board, swapping: pos, with: up) {
                        return true
                    }
                }
            }
        }
        return false
    }

    // MARK: - Horizontal Runs

    private func findHorizontalRuns(on board: Board) -> [Run] {
        var runs: [Run] = []

        for row in 0..<board.numRows {
            var col = 0
            while col < board.numColumns {
                guard let gem = board[row, col], board.isPlayable(row: row, col: col) else {
                    col += 1
                    continue
                }

                // Skip crystal balls (they don't form matches by themselves)
                if gem.special == .crystalBall {
                    col += 1
                    continue
                }

                var runLength = 1
                var positions: [GridPosition] = [GridPosition(row: row, column: col)]

                while col + runLength < board.numColumns {
                    let nextPos = GridPosition(row: row, column: col + runLength)
                    guard let nextGem = board[nextPos],
                          nextGem.color == gem.color,
                          nextGem.special != .crystalBall,
                          board.isPlayable(nextPos) else { break }
                    positions.append(nextPos)
                    runLength += 1
                }

                if runLength >= 3 {
                    runs.append(Run(positions: positions, color: gem.color, isHorizontal: true))
                }

                col += max(1, runLength)
            }
        }

        return runs
    }

    // MARK: - Vertical Runs

    private func findVerticalRuns(on board: Board) -> [Run] {
        var runs: [Run] = []

        for col in 0..<board.numColumns {
            var row = 0
            while row < board.numRows {
                guard let gem = board[row, col], board.isPlayable(row: row, col: col) else {
                    row += 1
                    continue
                }

                if gem.special == .crystalBall {
                    row += 1
                    continue
                }

                var runLength = 1
                var positions: [GridPosition] = [GridPosition(row: row, column: col)]

                while row + runLength < board.numRows {
                    let nextPos = GridPosition(row: row + runLength, column: col)
                    guard let nextGem = board[nextPos],
                          nextGem.color == gem.color,
                          nextGem.special != .crystalBall,
                          board.isPlayable(nextPos) else { break }
                    positions.append(nextPos)
                    runLength += 1
                }

                if runLength >= 3 {
                    runs.append(Run(positions: positions, color: gem.color, isHorizontal: false))
                }

                row += max(1, runLength)
            }
        }

        return runs
    }

    // MARK: - 2x2 Square Matches

    private func findSquareMatches(on board: Board) -> [MatchResult] {
        var results: [MatchResult] = []
        var usedPositions: Set<GridPosition> = []

        for row in 0..<(board.numRows - 1) {
            for col in 0..<(board.numColumns - 1) {
                let positions = [
                    GridPosition(row: row, column: col),
                    GridPosition(row: row, column: col + 1),
                    GridPosition(row: row + 1, column: col),
                    GridPosition(row: row + 1, column: col + 1)
                ]

                // All must be playable and have gems of same color
                guard positions.allSatisfy({ board.isPlayable($0) }) else { continue }
                let gems = positions.compactMap { board[$0] }
                guard gems.count == 4 else { continue }
                guard gems.allSatisfy({ $0.color == gems[0].color && $0.special != .crystalBall }) else { continue }

                let posSet = Set(positions)
                // Don't create if these positions are already part of a larger match
                // (Square detection is secondary to line detection)
                if !posSet.isSubset(of: usedPositions) {
                    let center = GridPosition(row: row, column: col) // bottom-left as special position
                    results.append(MatchResult(
                        positions: posSet,
                        pattern: .square,
                        color: gems[0].color,
                        specialPosition: center,
                        specialType: .miningDrone
                    ))
                    usedPositions.formUnion(posSet)
                }
            }
        }

        return results
    }

    // MARK: - Merge Overlapping Runs

    private func mergeRuns(horizontal: [Run], vertical: [Run], board: Board) -> [MatchResult] {
        var results: [MatchResult] = []
        var consumed = Set<Int>()

        // Try to merge overlapping H+V runs of same color
        for (i, hRun) in horizontal.enumerated() {
            for (j, vRun) in vertical.enumerated() {
                guard hRun.color == vRun.color else { continue }

                let hSet = Set(hRun.positions)
                let vSet = Set(vRun.positions)
                let intersection = hSet.intersection(vSet)

                if !intersection.isEmpty {
                    let merged = hSet.union(vSet)
                    let pattern = classifyMergedShape(horizontal: hRun, vertical: vRun)

                    // Special position is at the intersection
                    let specialPos = intersection.first!
                    let specialType = MatchResult.specialFor(pattern: pattern, isHorizontal: true)

                    results.append(MatchResult(
                        positions: merged,
                        pattern: pattern,
                        color: hRun.color,
                        specialPosition: specialPos,
                        specialType: specialType
                    ))

                    consumed.insert(i)
                    consumed.insert(horizontal.count + j)
                }
            }
        }

        // Add unmerged runs as standalone matches
        for (i, run) in horizontal.enumerated() {
            if !consumed.contains(i) {
                results.append(runToMatchResult(run))
            }
        }
        for (j, run) in vertical.enumerated() {
            if !consumed.contains(horizontal.count + j) {
                results.append(runToMatchResult(run))
            }
        }

        return results
    }

    private func classifyMergedShape(horizontal: Run, vertical: Run) -> MatchPattern {
        let totalUnique = Set(horizontal.positions).union(Set(vertical.positions)).count
        if totalUnique >= 5 {
            // Check if it's an L or T shape
            let hSet = Set(horizontal.positions)
            let vSet = Set(vertical.positions)
            let intersection = hSet.intersection(vSet)

            if let corner = intersection.first {
                // T-shape: intersection is in the middle of one run
                let hMiddle = horizontal.positions.count > 2 &&
                    corner != horizontal.positions.first && corner != horizontal.positions.last
                let vMiddle = vertical.positions.count > 2 &&
                    corner != vertical.positions.first && corner != vertical.positions.last

                if hMiddle || vMiddle {
                    return .tShape
                }
            }
            return .lShape
        }
        // If combined < 5, treat as the larger of the two runs
        let maxLen = max(horizontal.positions.count, vertical.positions.count)
        if maxLen >= 5 { return .five }
        if maxLen >= 4 { return .four }
        return .three
    }

    private func runToMatchResult(_ run: Run) -> MatchResult {
        let count = run.positions.count
        let pattern: MatchPattern
        let specialType: SpecialType?

        switch count {
        case 5...:
            pattern = .five
            specialType = .crystalBall
        case 4:
            pattern = .four
            // Laser direction is perpendicular to the match direction
            specialType = run.isHorizontal ? .laserVertical : .laserHorizontal
        default:
            pattern = .three
            specialType = nil
        }

        // Special gem goes where the player's swapped gem was, or middle of run
        let specialPos = run.positions[count / 2]

        return MatchResult(
            positions: Set(run.positions),
            pattern: pattern,
            color: run.color,
            specialPosition: specialPos,
            specialType: specialType
        )
    }
}

// MARK: - Run (internal)

private struct Run {
    let positions: [GridPosition]
    let color: GemColor
    let isHorizontal: Bool
}
