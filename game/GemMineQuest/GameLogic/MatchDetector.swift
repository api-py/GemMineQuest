import Foundation

class MatchDetector {

    // MARK: - Public API

    /// Find all matches on the board using the Candy Crush reference algorithm:
    /// Sliding window scan for horizontal then vertical, collect ALL matched positions,
    /// then classify patterns to determine special gem creation.
    func detectMatches(on board: Board) -> [MatchResult] {
        var horizontalSegments: [Segment] = []
        var verticalSegments: [Segment] = []

        // Phase 1: Find all horizontal segments of 3+
        for row in 0..<board.numRows {
            var col = 0
            while col <= board.numColumns - 3 {
                guard let gem = board[row, col],
                      board.isPlayable(row: row, col: col),
                      gem.special != .crystalBall else {
                    col += 1; continue
                }
                let color = gem.color
                guard let gem2 = board[row, col + 1], gem2.color == color, gem2.special != .crystalBall,
                      board.isPlayable(row: row, col: col + 1),
                      let gem3 = board[row, col + 2], gem3.color == color, gem3.special != .crystalBall,
                      board.isPlayable(row: row, col: col + 2) else {
                    col += 1; continue
                }
                // Found at least 3 — extend as far as possible
                var end = col + 2
                while end + 1 < board.numColumns,
                      let nextGem = board[row, end + 1],
                      nextGem.color == color,
                      nextGem.special != .crystalBall,
                      board.isPlayable(row: row, col: end + 1) {
                    end += 1
                }
                let positions = (col...end).map { GridPosition(row: row, column: $0) }
                horizontalSegments.append(Segment(positions: positions, color: color, isHorizontal: true))
                col = end + 1 // Skip past this segment
            }
        }

        // Phase 2: Find all vertical segments of 3+
        for col in 0..<board.numColumns {
            var row = 0
            while row <= board.numRows - 3 {
                guard let gem = board[row, col],
                      board.isPlayable(row: row, col: col),
                      gem.special != .crystalBall else {
                    row += 1; continue
                }
                let color = gem.color
                guard let gem2 = board[row + 1, col], gem2.color == color, gem2.special != .crystalBall,
                      board.isPlayable(row: row + 1, col: col),
                      let gem3 = board[row + 2, col], gem3.color == color, gem3.special != .crystalBall,
                      board.isPlayable(row: row + 2, col: col) else {
                    row += 1; continue
                }
                var end = row + 2
                while end + 1 < board.numRows,
                      let nextGem = board[end + 1, col],
                      nextGem.color == color,
                      nextGem.special != .crystalBall,
                      board.isPlayable(row: end + 1, col: col) {
                    end += 1
                }
                let positions = (row...end).map { GridPosition(row: $0, column: col) }
                verticalSegments.append(Segment(positions: positions, color: color, isHorizontal: false))
                row = end + 1
            }
        }

        // Phase 3: Find 2×2 square matches
        var squareResults: [MatchResult] = []
        var squareUsed = Set<GridPosition>()
        for row in 0..<(board.numRows - 1) {
            for col in 0..<(board.numColumns - 1) {
                let positions = [
                    GridPosition(row: row, column: col), GridPosition(row: row, column: col + 1),
                    GridPosition(row: row + 1, column: col), GridPosition(row: row + 1, column: col + 1)
                ]
                guard positions.allSatisfy({ board.isPlayable($0) }) else { continue }
                let gems = positions.compactMap { board[$0] }
                guard gems.count == 4,
                      gems.allSatisfy({ $0.color == gems[0].color && $0.special != .crystalBall }) else { continue }
                let posSet = Set(positions)
                if posSet.isDisjoint(with: squareUsed) {
                    squareResults.append(MatchResult(
                        positions: posSet, pattern: .square, color: gems[0].color,
                        specialPosition: positions[0], specialType: .miningDrone
                    ))
                    squareUsed.formUnion(posSet)
                }
            }
        }

        // Phase 4: Classify segments into specials (L/T → wrapped, 5+ → color bomb, 4 → striped)
        let segmentResults = classifySegments(horizontal: horizontalSegments, vertical: verticalSegments)

        // Phase 5: Deduplicate squares against higher-priority segment results
        // L/T shapes (priority 80) beat squares (priority 40)
        let coveredBySegments = segmentResults.reduce(into: Set<GridPosition>()) { $0.formUnion($1.positions) }
        // Only discard a square if ALL 4 of its positions are already covered by segment matches
        let filteredSquares = squareResults.filter { !$0.positions.isSubset(of: coveredBySegments) }

        return segmentResults + filteredSquares
    }

    func wouldMatch(board: Board, swapping posA: GridPosition, with posB: GridPosition) -> Bool {
        board.swapGems(posA, posB)
        let matches = detectMatches(on: board)
        board.swapGems(posA, posB)
        return !matches.isEmpty
    }

    /// Find the best possible swap move, prioritizing special gem creation.
    /// Returns (posA, posB) for the swap, or nil if no valid moves.
    func findBestMove(on board: Board) -> (GridPosition, GridPosition)? {
        var bestMove: (GridPosition, GridPosition)?
        var bestPriority: Int = -1
        var bestCount: Int = 0

        for row in 0..<board.numRows {
            for col in 0..<board.numColumns {
                let pos = GridPosition(row: row, column: col)
                guard board[pos] != nil, board.isPlayable(pos) else { continue }

                let neighbors = [
                    GridPosition(row: row, column: col + 1),
                    GridPosition(row: row + 1, column: col)
                ]

                for neighbor in neighbors {
                    guard board.isValidPosition(neighbor),
                          board[neighbor] != nil,
                          board.isPlayable(neighbor) else { continue }

                    board.swapGems(pos, neighbor)
                    let matches = detectMatches(on: board)
                    board.swapGems(pos, neighbor)

                    if matches.isEmpty { continue }

                    // Score this move by best pattern priority and total gem count
                    let maxPriority = matches.map { $0.pattern.priority }.max() ?? 0
                    let totalCount = matches.reduce(0) { $0 + $1.positions.count }

                    if maxPriority > bestPriority || (maxPriority == bestPriority && totalCount > bestCount) {
                        bestPriority = maxPriority
                        bestCount = totalCount
                        bestMove = (pos, neighbor)
                    }
                }
            }
        }

        return bestMove
    }

    func hasAnyValidMove(on board: Board) -> Bool {
        for row in 0..<board.numRows {
            for col in 0..<board.numColumns {
                let pos = GridPosition(row: row, column: col)
                guard board[pos] != nil, board.isPlayable(pos) else { continue }
                let right = GridPosition(row: row, column: col + 1)
                if board.isValidPosition(right) && board[right] != nil && board.isPlayable(right) {
                    if wouldMatch(board: board, swapping: pos, with: right) { return true }
                }
                let up = GridPosition(row: row + 1, column: col)
                if board.isValidPosition(up) && board[up] != nil && board.isPlayable(up) {
                    if wouldMatch(board: board, swapping: pos, with: up) { return true }
                }
            }
        }
        return false
    }

    // MARK: - Classification (reference algorithm Section 2)

    private func classifySegments(horizontal: [Segment], vertical: [Segment]) -> [MatchResult] {
        var results: [MatchResult] = []
        var consumedH = Set<Int>()
        var consumedV = Set<Int>()

        // PRIORITY 1: Any single segment of 5+ in a line → Crystal Ball (HIGHEST PRIORITY)
        for (i, seg) in horizontal.enumerated() {
            if seg.positions.count >= 5 {
                results.append(MatchResult(
                    positions: Set(seg.positions), pattern: .five, color: seg.color,
                    specialPosition: seg.positions[seg.positions.count / 2], specialType: .crystalBall
                ))
                consumedH.insert(i)
            }
        }
        for (j, seg) in vertical.enumerated() {
            if seg.positions.count >= 5 {
                results.append(MatchResult(
                    positions: Set(seg.positions), pattern: .five, color: seg.color,
                    specialPosition: seg.positions[seg.positions.count / 2], specialType: .crystalBall
                ))
                consumedV.insert(j)
            }
        }

        // PRIORITY 2: L/T intersections → Volatile (Wrapped)
        for (i, hSeg) in horizontal.enumerated() {
            guard !consumedH.contains(i) else { continue }
            for (j, vSeg) in vertical.enumerated() {
                guard !consumedV.contains(j) else { continue }
                guard hSeg.color == vSeg.color else { continue }

                let hSet = Set(hSeg.positions)
                let vSet = Set(vSeg.positions)
                let intersection = hSet.intersection(vSet)
                guard !intersection.isEmpty else { continue }

                let merged = hSet.union(vSet)
                if merged.count >= 5, let intersectionPos = intersection.first {
                    results.append(MatchResult(
                        positions: merged, pattern: .lShape, color: hSeg.color,
                        specialPosition: intersectionPos, specialType: .volatile
                    ))
                    consumedH.insert(i)
                    consumedV.insert(j)
                }
            }
        }

        // PRIORITY 3: Remaining 4-in-line → Striped, 3-in-line → normal
        for (i, seg) in horizontal.enumerated() {
            guard !consumedH.contains(i) else { continue }
            results.append(segmentToResult(seg))
        }
        for (j, seg) in vertical.enumerated() {
            guard !consumedV.contains(j) else { continue }
            results.append(segmentToResult(seg))
        }

        // Deduplicate: higher-priority results take precedence
        var finalResults: [MatchResult] = []
        let sorted = results.sorted { priorityScore($0) > priorityScore($1) }
        var covered = Set<GridPosition>()
        for result in sorted {
            if result.specialType != nil || !result.positions.isSubset(of: covered) {
                finalResults.append(result)
                covered.formUnion(result.positions)
            }
        }

        return finalResults
    }

    /// Priority: Crystal Ball (5) > Volatile/L-shape (4) > Striped/4-match (3) > normal (1)
    private func priorityScore(_ result: MatchResult) -> Int {
        switch result.pattern {
        case .five: return 100    // Crystal Ball — always highest
        case .lShape, .tShape: return 80  // Volatile
        case .four: return 60     // Laser
        case .square: return 40   // Drone
        case .three: return 20    // Normal
        }
    }

    private func segmentToResult(_ seg: Segment) -> MatchResult {
        let count = seg.positions.count
        if count >= 5 {
            return MatchResult(positions: Set(seg.positions), pattern: .five, color: seg.color,
                               specialPosition: seg.positions[count / 2], specialType: .crystalBall)
        } else if count == 4 {
            // Perpendicular direction: horizontal match → vertical laser, vertical → horizontal
            let specialType: SpecialType = seg.isHorizontal ? .laserVertical : .laserHorizontal
            return MatchResult(positions: Set(seg.positions), pattern: .four, color: seg.color,
                               specialPosition: seg.positions[count / 2], specialType: specialType)
        } else {
            return MatchResult(positions: Set(seg.positions), pattern: .three, color: seg.color,
                               specialPosition: nil, specialType: nil)
        }
    }
}

private struct Segment {
    let positions: [GridPosition]
    let color: GemColor
    let isHorizontal: Bool
}
