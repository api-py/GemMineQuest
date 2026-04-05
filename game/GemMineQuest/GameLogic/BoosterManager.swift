import Foundation

@MainActor
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
            guard let gem = board[$0] else { return false }
            return gem.special == .none
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
            guard let gem = board[$0] else { return false }
            return gem.special == .none
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

    /// Gem Forge: places a Crystal Ball and a Volatile gem on two random board positions
    func useGemForge(on board: Board) -> [GameEvent] {
        var events: [GameEvent] = [.boosterUsed(type: .gemForge)]

        let candidates = board.allPlayablePositions().filter {
            guard let gem = board[$0] else { return false }
            return gem.special == .none
        }.shuffled()

        // Filter out positions adjacent to existing specials (least priority for crystal ball)
        let filteredCandidates = candidates.filter { pos in
            let neighbors = [
                GridPosition(row: pos.row-1, column: pos.column),
                GridPosition(row: pos.row+1, column: pos.column),
                GridPosition(row: pos.row, column: pos.column-1),
                GridPosition(row: pos.row, column: pos.column+1)
            ]
            return !neighbors.contains { neighbor in
                guard let gem = board[neighbor] else { return false }
                return gem.special == .crystalBall || gem.special == .volatile ||
                       gem.special == .laserHorizontal || gem.special == .laserVertical
            }
        }
        let finalCandidates = filteredCandidates.isEmpty ? candidates : filteredCandidates

        // Place Crystal Ball on the first candidate
        if let pos = finalCandidates.first, var gem = board[pos] {
            gem.special = .crystalBall
            board.setGem(gem, at: pos)
            events.append(.specialCreated(type: .crystalBall, color: gem.color, at: pos))
        }

        // Place Volatile on the second candidate
        if finalCandidates.count > 1, var gem = board[finalCandidates[1]] {
            gem.special = .volatile
            board.setGem(gem, at: finalCandidates[1])
            events.append(.specialCreated(type: .volatile, color: gem.color, at: finalCandidates[1]))
        }

        return events
    }

    /// Dynamite: destroy 3x3 area (9 gems) around the tapped position
    func useDynamite(at pos: GridPosition, on board: Board, state: GameState) -> [GameEvent] {
        var events: [GameEvent] = [.boosterUsed(type: .dynamite)]
        var affected = Set<GridPosition>()

        for dr in -1...1 {
            for dc in -1...1 {
                let target = GridPosition(row: pos.row + dr, column: pos.column + dc)
                guard board.isValidPosition(target) && board.isPlayable(target) else { continue }
                if let gem = board[target], gem.special != .none {
                    let specialAffected = specialResolver.resolve(special: gem.special, at: target, on: board)
                    affected.formUnion(specialAffected)
                }
                affected.insert(target)
            }
        }

        events.append(.matched(positions: affected, chainIndex: 0))

        for target in affected {
            board.removeGem(at: target)
            if board.blockerAt(target) != nil {
                board.setBlocker(nil, at: target)
                events.append(.blockerDestroyed(at: target))
            }
        }

        let delta = affected.count * 60
        state.score += delta
        events.append(.scoreUpdated(newScore: state.score, delta: delta, at: pos))

        return events
    }

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

    /// Mine Cart Rush: randomly place 5 laser gems on the board (never replacing specials)
    func useMineCartRush(row: Int, on board: Board) -> [GameEvent] {
        var events: [GameEvent] = [.boosterUsed(type: .mineCartRush)]

        // Collect all normal gems on the board (no specials, no blockers)
        var candidates: [GridPosition] = []
        for r in 0..<board.numRows {
            for c in 0..<board.numColumns {
                let pos = GridPosition(row: r, column: c)
                guard board.isPlayable(pos),
                      let gem = board[pos],
                      gem.special == .none,
                      board.blockerAt(pos) == nil else { continue }
                candidates.append(pos)
            }
        }

        // Place exactly 3 random laser gems
        candidates.shuffle()
        let count = min(3, candidates.count)
        for i in 0..<count {
            let pos = candidates[i]
            guard var gem = board[pos] else { continue }
            let direction: SpecialType = Bool.random() ? .laserHorizontal : .laserVertical
            gem.special = direction
            board.setGem(gem, at: pos)
            events.append(.specialCreated(type: direction, color: gem.color, at: pos))
        }

        return events
    }
}
