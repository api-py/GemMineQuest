import Foundation

class BlockerManager {

    private var lavaCooldownTurns: Int = 0

    func notifyLavaDestroyed() {
        lavaCooldownTurns = 1
    }

    /// Apply one hit of damage to the blocker at the given position.
    /// Granite loses a layer; other destructible blockers are removed entirely.
    func damageBlocker(at pos: GridPosition, on board: Board) -> GameEvent? {
        guard let blocker = board.blockerAt(pos) else { return nil }
        switch blocker {
        case .granite(let layers):
            if layers > 1 {
                board.setBlocker(.granite(layers: layers - 1), at: pos)
                return .blockerDamaged(at: pos, type: blocker)
            } else {
                board.setBlocker(nil, at: pos)
                return .blockerDestroyed(at: pos)
            }
        default:
            board.setBlocker(nil, at: pos)
            return .blockerDestroyed(at: pos)
        }
    }

    /// Damage blockers directly on the affected positions (e.g. laser/volatile paths).
    /// Only handles granite, cage, and amber to match direct-path damage semantics.
    func damageBlockersInPath(_ positions: Set<GridPosition>,
                              on board: Board,
                              alreadyDamaged: Set<GridPosition> = []) -> [GameEvent] {
        var events: [GameEvent] = []
        for pos in positions where !alreadyDamaged.contains(pos) {
            guard let blocker = board.blockerAt(pos) else { continue }
            switch blocker {
            case .granite(let layers):
                if layers > 1 {
                    board.setBlocker(.granite(layers: layers - 1), at: pos)
                    events.append(.blockerDamaged(at: pos, type: blocker))
                } else {
                    board.setBlocker(nil, at: pos)
                    events.append(.blockerDestroyed(at: pos))
                }
            case .cage, .amber:
                board.setBlocker(nil, at: pos)
                events.append(.blockerDestroyed(at: pos))
            default:
                break
            }
        }
        return events
    }

    /// Process blockers adjacent to matched positions.
    /// Returns events for blocker damage/destruction.
    func processMatchAdjacent(matchedPositions: Set<GridPosition>,
                               on board: Board) -> [GameEvent] {
        var events: [GameEvent] = []
        var processedBlockers = Set<GridPosition>()

        for matchPos in matchedPositions {
            for neighbor in matchPos.neighbors {
                guard board.isValidPosition(neighbor),
                      !processedBlockers.contains(neighbor),
                      let blocker = board.blockerAt(neighbor) else { continue }

                processedBlockers.insert(neighbor)

                switch blocker {
                case .granite(let layers):
                    if layers > 1 {
                        board.setBlocker(.granite(layers: layers - 1), at: neighbor)
                        events.append(.blockerDamaged(at: neighbor, type: blocker))
                    } else {
                        board.setBlocker(nil, at: neighbor)
                        events.append(.blockerDestroyed(at: neighbor))
                    }

                case .boulder:
                    board.setBlocker(nil, at: neighbor)
                    events.append(.blockerDestroyed(at: neighbor))

                case .amber:
                    board.setBlocker(nil, at: neighbor)
                    events.append(.blockerDestroyed(at: neighbor))

                case .cage:
                    // Cage is freed when the gem inside is matched
                    if matchedPositions.contains(neighbor) {
                        board.setBlocker(nil, at: neighbor)
                        events.append(.blockerDestroyed(at: neighbor))
                    }

                case .lava:
                    board.setBlocker(nil, at: neighbor)
                    events.append(.blockerDestroyed(at: neighbor))
                    notifyLavaDestroyed()

                case .tnt:
                    // TNT is cleared by adjacent match
                    board.setBlocker(nil, at: neighbor)
                    board.removeGem(at: neighbor)
                    events.append(.blockerDestroyed(at: neighbor))
                }
            }
        }

        // Also check if any matched positions had cages
        for pos in matchedPositions {
            if let blocker = board.blockerAt(pos) {
                if case .cage = blocker {
                    board.setBlocker(nil, at: pos)
                    events.append(.blockerDestroyed(at: pos))
                }
                if case .amber = blocker {
                    board.setBlocker(nil, at: pos)
                    events.append(.blockerDestroyed(at: pos))
                }
            }
        }

        return events
    }

    /// Process end-of-turn effects (lava spreading, TNT countdown)
    func processEndOfTurn(on board: Board) -> [GameEvent] {
        var events: [GameEvent] = []

        // TNT countdown
        events.append(contentsOf: processTNTCountdown(on: board))

        // Lava spreading
        events.append(contentsOf: processLavaSpread(on: board))

        return events
    }

    /// Decrement TNT countdowns. Returns tntExploded if any reach 0.
    private func processTNTCountdown(on board: Board) -> [GameEvent] {
        var events: [GameEvent] = []

        for row in 0..<board.numRows {
            for col in 0..<board.numColumns {
                let pos = GridPosition(row: row, column: col)
                if case .tnt(let countdown) = board.blockerAt(pos) {
                    let newCountdown = countdown - 1
                    if newCountdown <= 0 {
                        events.append(.tntExploded(at: pos))
                    } else {
                        board.setBlocker(.tnt(countdown: newCountdown), at: pos)
                        events.append(.tntWarning(at: pos, countdown: newCountdown))
                    }
                }
            }
        }

        return events
    }

    /// Spread lava to adjacent empty tiles
    private func processLavaSpread(on board: Board) -> [GameEvent] {
        var events: [GameEvent] = []

        // Cooldown: skip spreading if lava was recently destroyed
        if lavaCooldownTurns > 0 {
            lavaCooldownTurns -= 1
            return events
        }

        // Collect all lava positions
        var lavaPositions: [GridPosition] = []
        for row in 0..<board.numRows {
            for col in 0..<board.numColumns {
                let pos = GridPosition(row: row, column: col)
                if case .lava = board.blockerAt(pos) {
                    lavaPositions.append(pos)
                }
            }
        }

        guard !lavaPositions.isEmpty else { return events }

        // Only ONE lava tile spreads per turn (randomly selected)
        lavaPositions.shuffle()

        for lavaPos in lavaPositions {
            // Priority: down first, then sideways (shuffled), then up
            let down = GridPosition(row: lavaPos.row - 1, column: lavaPos.column)
            let left = GridPosition(row: lavaPos.row, column: lavaPos.column - 1)
            let right = GridPosition(row: lavaPos.row, column: lavaPos.column + 1)
            let up = GridPosition(row: lavaPos.row + 1, column: lavaPos.column)

            var prioritized: [GridPosition] = []
            // 1. Down (gravity)
            prioritized.append(down)
            // 2. Sideways (shuffled)
            if Bool.random() {
                prioritized.append(contentsOf: [left, right])
            } else {
                prioritized.append(contentsOf: [right, left])
            }
            // 3. Up (last resort)
            prioritized.append(up)

            for neighbor in prioritized {
                if board.isValidPosition(neighbor) &&
                   board.isPlayable(neighbor) &&
                   board.blockerAt(neighbor) == nil &&
                   board[neighbor] != nil {
                    board.setBlocker(.lava, at: neighbor)
                    board.removeGem(at: neighbor)
                    events.append(.lavaSpread(from: lavaPos, to: neighbor))
                    return events  // Only ONE spread per turn total
                }
            }
        }

        return events
    }

    /// Check if any TNT has exploded (game over condition)
    func hasTNTExploded(events: [GameEvent]) -> Bool {
        events.contains(where: {
            if case .tntExploded = $0 { return true }
            return false
        })
    }
}
