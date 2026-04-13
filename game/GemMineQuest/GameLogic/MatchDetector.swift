import Foundation

class MatchDetector {

    // MARK: - Public API

    /// Find all matches on the board using the Candy Crush reference algorithm:
    /// Sliding window scan for horizontal then vertical, collect ALL matched positions,
    /// then classify patterns to determine special gem creation.
    func detectMatches(on board: Board) -> [MatchResult] {
        // Phase 1 & 2: Find all horizontal and vertical segments of 3+
        let horizontalSegments = findSegments(on: board, primaryCount: board.numColumns,
                                               secondaryCount: board.numRows, isHorizontal: true)
        let verticalSegments = findSegments(on: board, primaryCount: board.numRows,
                                             secondaryCount: board.numColumns, isHorizontal: false)

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

        // Phase 5: Only discard squares if a HIGHER priority special covers them.
        // Normal 3-matches (priority 20) should NOT suppress drones (priority 40).
        let highPriorityPositions = segmentResults
            .filter { ($0.specialType != nil) && (priorityScore($0) > 40) }
            .reduce(into: Set<GridPosition>()) { $0.formUnion($1.positions) }
        let filteredSquares = squareResults.filter { !$0.positions.isSubset(of: highPriorityPositions) }

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
                guard board[pos] != nil, board.isPlayable(pos),
                      board.blockerAt(pos) == nil else { continue }

                let neighbors = [
                    GridPosition(row: row, column: col + 1),
                    GridPosition(row: row + 1, column: col)
                ]

                for neighbor in neighbors {
                    guard board.isValidPosition(neighbor),
                          board[neighbor] != nil,
                          board.isPlayable(neighbor),
                          board.blockerAt(neighbor) == nil else { continue }

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
                guard board[pos] != nil, board.isPlayable(pos),
                      board.blockerAt(pos) == nil else { continue }
                let right = GridPosition(row: row, column: col + 1)
                if board.isValidPosition(right) && board[right] != nil && board.isPlayable(right)
                    && board.blockerAt(right) == nil {
                    if wouldMatch(board: board, swapping: pos, with: right) { return true }
                }
                let up = GridPosition(row: row + 1, column: col)
                if board.isValidPosition(up) && board[up] != nil && board.isPlayable(up)
                    && board.blockerAt(up) == nil {
                    if wouldMatch(board: board, swapping: pos, with: up) { return true }
                }
            }
        }
        return false
    }

    // MARK: - Segment Scanning

    /// Unified segment finder for both horizontal and vertical directions.
    /// `primaryCount` is the axis being scanned (columns for horizontal, rows for vertical).
    /// `secondaryCount` is the perpendicular axis (rows for horizontal, columns for vertical).
    private func findSegments(on board: Board, primaryCount: Int, secondaryCount: Int, isHorizontal: Bool) -> [Segment] {
        var segments: [Segment] = []
        for secondary in 0..<secondaryCount {
            var primary = 0
            while primary <= primaryCount - 3 {
                let row = isHorizontal ? secondary : primary
                let col = isHorizontal ? primary : secondary
                guard let gem = board[row, col],
                      board.isPlayable(row: row, col: col),
                      gem.special != .crystalBall else {
                    primary += 1; continue
                }
                let color = gem.color
                let r1 = isHorizontal ? secondary : primary + 1
                let c1 = isHorizontal ? primary + 1 : secondary
                let r2 = isHorizontal ? secondary : primary + 2
                let c2 = isHorizontal ? primary + 2 : secondary
                guard let gem2 = board[r1, c1], gem2.color == color, gem2.special != .crystalBall,
                      board.isPlayable(row: r1, col: c1),
                      let gem3 = board[r2, c2], gem3.color == color, gem3.special != .crystalBall,
                      board.isPlayable(row: r2, col: c2) else {
                    primary += 1; continue
                }
                var end = primary + 2
                while end + 1 < primaryCount {
                    let nr = isHorizontal ? secondary : end + 1
                    let nc = isHorizontal ? end + 1 : secondary
                    guard let nextGem = board[nr, nc],
                          nextGem.color == color,
                          nextGem.special != .crystalBall,
                          board.isPlayable(row: nr, col: nc) else { break }
                    end += 1
                }
                let positions = (primary...end).map { p in
                    isHorizontal ? GridPosition(row: secondary, column: p) : GridPosition(row: p, column: secondary)
                }
                segments.append(Segment(positions: positions, color: color, isHorizontal: isHorizontal))
                primary = end + 1
            }
        }
        return segments
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
