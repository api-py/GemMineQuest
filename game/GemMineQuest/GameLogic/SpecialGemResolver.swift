import Foundation

class SpecialGemResolver {

    /// Resolve what happens when a special gem is activated.
    /// Returns the set of positions affected.
    func resolve(special: SpecialType, at position: GridPosition,
                 on board: Board) -> Set<GridPosition> {
        switch special {
        case .none:
            return []
        case .laserHorizontal:
            return resolveHorizontalLaser(at: position, on: board)
        case .laserVertical:
            return resolveVerticalLaser(at: position, on: board)
        case .volatile:
            return resolveVolatile(at: position, on: board)
        case .crystalBall:
            return [] // Crystal ball needs a target color, handled in combo
        case .miningDrone:
            return [] // Drones are handled separately with animation
        }
    }

    /// Resolve a combo between two special gems being swapped.
    /// Returns (affected positions, events for any chain reactions)
    func resolveCombo(specialA: SpecialType, posA: GridPosition,
                      specialB: SpecialType, posB: GridPosition,
                      on board: Board) -> Set<GridPosition> {
        let typeA = specialA
        let typeB = specialB

        // Crystal Ball + Crystal Ball = clear entire board
        if typeA == .crystalBall && typeB == .crystalBall {
            return Set(board.allPlayablePositions().filter { board[$0] != nil })
        }

        // Crystal Ball + anything
        if typeA == .crystalBall || typeB == .crystalBall {
            let otherPos = typeA == .crystalBall ? posB : posA
            let otherSpecial = typeA == .crystalBall ? typeB : typeA
            guard let targetGem = board[otherPos] else { return [] }
            return resolveCrystalBallCombo(targetColor: targetGem.color,
                                           otherSpecial: otherSpecial,
                                           on: board)
        }

        // Laser + Laser = giant cross
        if typeA.isLaser && typeB.isLaser {
            let hPositions = resolveHorizontalLaser(at: posA, on: board)
            let vPositions = resolveVerticalLaser(at: posA, on: board)
            return hPositions.union(vPositions)
        }

        // Volatile + Volatile = 5x5 area
        if typeA == .volatile && typeB == .volatile {
            return resolveArea(center: posA, radius: 2, on: board)
        }

        // Laser + Volatile = 3-wide cross
        if (typeA.isLaser && typeB == .volatile) || (typeA == .volatile && typeB.isLaser) {
            let center = typeA.isLaser ? posA : posB
            return resolveThickCross(at: center, on: board)
        }

        // Drone combos
        if typeA == .miningDrone || typeB == .miningDrone {
            // Drones carry the other special's effect - handled in GameEngine
            return []
        }

        return []
    }

    /// Crystal Ball activated on a target color
    func resolveCrystalBall(targetColor: GemColor, on board: Board) -> Set<GridPosition> {
        var affected = Set<GridPosition>()
        for pos in board.allPlayablePositions() {
            if let gem = board[pos], gem.color == targetColor {
                affected.insert(pos)
            }
        }
        return affected
    }

    // MARK: - Private Resolution Methods

    private func resolveHorizontalLaser(at pos: GridPosition, on board: Board) -> Set<GridPosition> {
        var affected = Set<GridPosition>()
        for col in 0..<board.numColumns {
            let target = GridPosition(row: pos.row, column: col)
            if board.isPlayable(target) {
                affected.insert(target)
            }
        }
        return affected
    }

    private func resolveVerticalLaser(at pos: GridPosition, on board: Board) -> Set<GridPosition> {
        var affected = Set<GridPosition>()
        for row in 0..<board.numRows {
            let target = GridPosition(row: row, column: pos.column)
            if board.isPlayable(target) {
                affected.insert(target)
            }
        }
        return affected
    }

    private func resolveVolatile(at pos: GridPosition, on board: Board) -> Set<GridPosition> {
        return resolveArea(center: pos, radius: 1, on: board)
    }

    private func resolveArea(center: GridPosition, radius: Int, on board: Board) -> Set<GridPosition> {
        var affected = Set<GridPosition>()
        for dr in -radius...radius {
            for dc in -radius...radius {
                let target = GridPosition(row: center.row + dr, column: center.column + dc)
                if board.isValidPosition(target) && board.isPlayable(target) {
                    affected.insert(target)
                }
            }
        }
        return affected
    }

    private func resolveThickCross(at center: GridPosition, on board: Board) -> Set<GridPosition> {
        var affected = Set<GridPosition>()
        // 3-wide row
        for col in 0..<board.numColumns {
            for dr in -1...1 {
                let target = GridPosition(row: center.row + dr, column: col)
                if board.isValidPosition(target) && board.isPlayable(target) {
                    affected.insert(target)
                }
            }
        }
        // 3-wide column
        for row in 0..<board.numRows {
            for dc in -1...1 {
                let target = GridPosition(row: row, column: center.column + dc)
                if board.isValidPosition(target) && board.isPlayable(target) {
                    affected.insert(target)
                }
            }
        }
        return affected
    }

    private func resolveCrystalBallCombo(targetColor: GemColor, otherSpecial: SpecialType,
                                          on board: Board) -> Set<GridPosition> {
        // Crystal Ball + regular special: all gems of that color get converted
        // to that special type, then all activate
        var affected = Set<GridPosition>()
        for pos in board.allPlayablePositions() {
            if let gem = board[pos], gem.color == targetColor {
                affected.insert(pos)
                // The conversion to specials happens in GameEngine
                // Here we just return which positions are affected
                let specialAffected = resolve(special: otherSpecial, at: pos, on: board)
                affected.formUnion(specialAffected)
            }
        }
        return affected
    }

    /// Get drone target positions (random gems, prioritizing objectives)
    func getDroneTargets(count: Int, on board: Board, prioritizeOre: Bool = true) -> [GridPosition] {
        var candidates: [GridPosition] = []
        var oreCandidates: [GridPosition] = []

        for pos in board.allPlayablePositions() {
            guard board[pos] != nil else { continue }
            if board.hasOreVein(at: pos) {
                oreCandidates.append(pos)
            }
            candidates.append(pos)
        }

        // Prioritize ore positions
        var targets: [GridPosition] = []
        if prioritizeOre {
            targets.append(contentsOf: oreCandidates.shuffled().prefix(count))
        }

        // Fill remaining with random positions
        let remaining = count - targets.count
        if remaining > 0 {
            let available = candidates.filter { !targets.contains($0) }.shuffled()
            targets.append(contentsOf: available.prefix(remaining))
        }

        return targets
    }
}
