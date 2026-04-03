import Foundation

class BoosterManager {

    private let specialResolver = SpecialGemResolver()

    // MARK: - Pre-Game Boosters

    /// Apply extra moves booster
    func applyExtraMoves(state: GameState) {
        state.movesRemaining += Constants.extraMovesCount
    }

    /// Place a crystal ball on the board
    func placeCrystalBall(on board: Board) -> GameEvent? {
        let candidates = board.allPlayablePositions().filter {
            board[$0] != nil && board[$0]?.special == SpecialType.none
        }
        guard let pos = candidates.randomElement() else { return nil }

        if var gem = board[pos] {
            gem.special = .crystalBall
            board.setGem(gem, at: pos)
            return .specialCreated(type: .crystalBall, color: gem.color, at: pos)
        }
        return nil
    }

    /// Place laser and volatile gems on the board
    func placePowerGems(on board: Board) -> [GameEvent] {
        var events: [GameEvent] = []
        let candidates = board.allPlayablePositions().filter {
            board[$0] != nil && board[$0]?.special == SpecialType.none
        }.shuffled()

        // Place one laser gem
        if let pos = candidates.first, var gem = board[pos] {
            let direction: SpecialType = Bool.random() ? .laserHorizontal : .laserVertical
            gem.special = direction
            board.setGem(gem, at: pos)
            events.append(.specialCreated(type: direction, color: gem.color, at: pos))
        }

        // Place one volatile gem
        if candidates.count > 1, let pos = candidates.dropFirst().first, var gem = board[pos] {
            gem.special = .volatile
            board.setGem(gem, at: pos)
            events.append(.specialCreated(type: .volatile, color: gem.color, at: pos))
        }

        return events
    }

    // MARK: - In-Game Boosters

    /// Pickaxe: destroy a single gem at position without using a move
    func usePickaxe(at pos: GridPosition, on board: Board, state: GameState) -> [GameEvent] {
        guard board.isPlayable(pos), board[pos] != nil else { return [] }

        var events: [GameEvent] = [.boosterUsed(type: .pickaxe)]

        // If gem is special, activate it
        if let gem = board[pos], gem.special != .none {
            let affected = specialResolver.resolve(special: gem.special, at: pos, on: board)
            if !affected.isEmpty {
                events.append(.specialActivated(type: gem.special, at: pos, affected: affected))
            }
        }

        // Remove the gem
        board.removeGem(at: pos)
        events.append(.matched(positions: [pos], chainIndex: 0))

        // Handle blockers
        if board.blockerAt(pos) != nil {
            board.setBlocker(nil, at: pos)
            events.append(.blockerDestroyed(at: pos))
        }

        // Score
        let delta = 60
        state.score += delta
        events.append(.scoreUpdated(newScore: state.score, delta: delta, at: pos))

        return events
    }

    /// Swap Charge: swap two adjacent gems without using a move
    func useSwapCharge(from posA: GridPosition, to posB: GridPosition,
                        on board: Board) -> [GameEvent] {
        guard GridPosition.isAdjacent(posA, posB),
              board[posA] != nil, board[posB] != nil else { return [] }

        board.swapGems(posA, posB)
        return [.boosterUsed(type: .swapCharge), .swap(from: posA, to: posB)]
    }

    /// Drone Strike: deploy 3 drones to clear random targets
    func useDroneStrike(on board: Board, state: GameState) -> [GameEvent] {
        var events: [GameEvent] = [.boosterUsed(type: .droneStrike)]

        let targets = specialResolver.getDroneTargets(
            count: Constants.droneStrikeCount,
            on: board,
            prioritizeOre: true
        )

        for target in targets {
            let center = board.allPlayablePositions().filter { board[$0] != nil }.randomElement() ?? target
            events.append(.droneDeployed(from: center, to: target))
            board.removeGem(at: target)

            let delta = 60
            state.score += delta
            events.append(.scoreUpdated(newScore: state.score, delta: delta, at: target))
        }

        return events
    }

    /// Mine Cart Rush: roll across a row turning gems into laser gems
    func useMineCartRush(row: Int, on board: Board) -> [GameEvent] {
        var events: [GameEvent] = [.boosterUsed(type: .mineCartRush)]

        for col in 0..<board.numColumns {
            let pos = GridPosition(row: row, column: col)
            guard board.isPlayable(pos), var gem = board[pos], gem.special == .none else { continue }

            let direction: SpecialType = Bool.random() ? .laserHorizontal : .laserVertical
            gem.special = direction
            board.setGem(gem, at: pos)
            events.append(.specialCreated(type: direction, color: gem.color, at: pos))
        }

        return events
    }
}
