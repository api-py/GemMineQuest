import Foundation

@MainActor
class ObjectiveTracker {

    /// Process a match and update game state objectives
    func processMatch(positions: Set<GridPosition>, on board: Board, state: GameState) -> [GameEvent] {
        var events: [GameEvent] = []

        for pos in positions {
            // Track ore clearing
            if board.hasOreVein(at: pos) {
                let fullyCleared = board.clearOreLayer(at: pos)
                if fullyCleared {
                    state.oreCleared += 1
                    events.append(.oreCleared(at: pos))
                } else {
                    events.append(.oreCracked(at: pos, remaining: true))
                }
            }

            // Track gem collection
            if let gem = board[pos] {
                state.gemsCollected[gem.color, default: 0] += 1

                if gem.special != .none {
                    state.specialsCollected[gem.special, default: 0] += 1
                }
            }
        }

        // Report objective progress and encouragement
        for objective in state.level.objectives {
            switch objective {
            case .reachScore(let target):
                events.append(.objectiveProgress(
                    text: "Score", current: state.score, target: target
                ))
                if state.score >= Int(Double(target) * 0.85) && state.score < target {
                    events.append(.encouragement(text: "Almost there!"))
                }
            case .clearAllOre:
                events.append(.objectiveProgress(
                    text: "Ore cleared", current: state.oreCleared, target: state.totalOre
                ))
                if state.totalOre > 0 && state.oreCleared == state.totalOre - 1 {
                    events.append(.encouragement(text: "Last ore vein!"))
                }
            case .dropTreasures(let count):
                events.append(.objectiveProgress(
                    text: "Treasures", current: state.treasuresDropped, target: count
                ))
                if state.treasuresDropped == count - 1 {
                    events.append(.encouragement(text: "One more treasure!"))
                }
            case .collectGems(let color, let count):
                let current = state.gemsCollected[color] ?? 0
                events.append(.objectiveProgress(
                    text: color.displayName, current: current, target: count
                ))
                if current >= count - 2 && current < count {
                    events.append(.encouragement(text: "\(count - current) \(color.displayName) left!"))
                }
            case .collectSpecials(let type, let count):
                let current = state.specialsCollected[type] ?? 0
                events.append(.objectiveProgress(
                    text: type.displayName, current: current, target: count
                ))
                if current == count - 1 {
                    events.append(.encouragement(text: "One more \(type.displayName)!"))
                }
            }
        }

        // Low moves warning
        if state.movesRemaining <= 3 && state.movesRemaining > 0 && !state.godModeEnabled {
            events.append(.encouragement(text: "\(state.movesRemaining) moves left!"))
        }

        return events
    }

    /// Check for treasure drops (ingredients reaching mine cart)
    func checkTreasureDrops(on board: Board, state: GameState) -> [GameEvent] {
        var events: [GameEvent] = []

        // Check row 0 for mine cart exits
        for col in 0..<board.numColumns {
            let pos = GridPosition(row: 0, column: col)
            if board.tileAt(pos) == .mineCart {
                // Check if there's a gem here that just fell
                if board[pos] != nil {
                    // This gem has reached the mine cart
                    board.removeGem(at: pos)
                    state.treasuresDropped += 1
                    events.append(.treasureDropped(at: pos))
                }
            }
        }

        return events
    }
}
