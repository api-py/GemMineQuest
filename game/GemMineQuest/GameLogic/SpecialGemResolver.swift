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

        // Volatile + Volatile = CLEAR ENTIRE BOARD
        if typeA == .volatile && typeB == .volatile {
            return Set(board.allPlayablePositions().filter { board[$0] != nil })
        }

        // Laser + Volatile = 3-wide cross
        if (typeA.isLaser && typeB == .volatile) || (typeA == .volatile && typeB.isLaser) {
            let center = typeA.isLaser ? posA : posB
            return resolveThickCross(at: center, on: board)
        }

        // Volatile + Drone = volatile teleports to random location and explodes there
        if (typeA == .volatile && typeB == .miningDrone) || (typeA == .miningDrone && typeB == .volatile) {
            let allPositions = board.allPlayablePositions().filter { board[$0] != nil }
            guard let randomPos = allPositions.randomElement() else { return [] }
            return resolveArea(center: randomPos, radius: 1, on: board)
        }

        // Drone + Drone = double explosion: two large 3x3 blasts at random locations
        if typeA == .miningDrone && typeB == .miningDrone {
            var affected = Set<GridPosition>()
            let allGemPositions = board.allPlayablePositions().filter { board[$0] != nil }
            // Two random explosion centers
            let centers = allGemPositions.shuffled().prefix(2)
            for center in centers {
                let area = resolveArea(center: center, radius: 2, on: board) // 5x5 area
                affected.formUnion(area)
            }
            // Also include positions A and B
            affected.insert(posA)
            affected.insert(posB)
            return affected
        }

        // Drone + Laser: drones carry the laser effect
        if typeA == .miningDrone || typeB == .miningDrone {
            let otherType = typeA == .miningDrone ? typeB : typeA
            let otherPos = typeA == .miningDrone ? posB : posA
            return resolve(special: otherType, at: otherPos, on: board)
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
        var lavaCandidates: [GridPosition] = []
        var oreCandidates: [GridPosition] = []

        for pos in board.allPlayablePositions() {
            guard board[pos] != nil else { continue }
            // Check if this position or any neighbor has lava
            if case .lava = board.blockerAt(pos) {
                lavaCandidates.append(pos)
            } else {
                let hasAdjacentLava = pos.neighbors.contains { neighbor in
                    guard board.isValidPosition(neighbor) else { return false }
                    if case .lava = board.blockerAt(neighbor) { return true }
                    return false
                }
                if hasAdjacentLava {
                    lavaCandidates.append(pos)
                }
            }
            if board.hasOreVein(at: pos) {
                oreCandidates.append(pos)
            }
            candidates.append(pos)
        }

        var targets: [GridPosition] = []
        // Priority 1: Lava positions
        targets.append(contentsOf: lavaCandidates.shuffled().prefix(count))
        // Priority 2: Ore positions
        let remaining1 = count - targets.count
        if remaining1 > 0 && prioritizeOre {
            let oreFiltered = oreCandidates.filter { !targets.contains($0) }.shuffled()
            targets.append(contentsOf: oreFiltered.prefix(remaining1))
        }
        // Priority 3: Random
        let remaining2 = count - targets.count
        if remaining2 > 0 {
            let available = candidates.filter { !targets.contains($0) }.shuffled()
            targets.append(contentsOf: available.prefix(remaining2))
        }
        return targets
    }
}
