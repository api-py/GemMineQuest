import Foundation

class BlockerManager {

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
        var newLavaPositions: [(from: GridPosition, to: GridPosition)] = []

        for row in 0..<board.numRows {
            for col in 0..<board.numColumns {
                let pos = GridPosition(row: row, column: col)
                guard case .lava = board.blockerAt(pos) else { continue }

                // Try to spread to a random adjacent position
                let shuffledNeighbors = pos.neighbors.shuffled()
                for neighbor in shuffledNeighbors {
                    if board.isValidPosition(neighbor) &&
                       board.isPlayable(neighbor) &&
                       board.blockerAt(neighbor) == nil &&
                       board[neighbor] != nil {
                        newLavaPositions.append((from: pos, to: neighbor))
                        break // Only spread to one neighbor per lava tile
                    }
                }
            }
        }

        // Apply lava spread
        for spread in newLavaPositions {
            board.setBlocker(.lava, at: spread.to)
            board.removeGem(at: spread.to)
            events.append(.lavaSpread(from: spread.from, to: spread.to))
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
