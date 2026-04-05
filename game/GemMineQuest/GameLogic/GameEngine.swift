import Foundation

@MainActor
class GameEngine {

    let state: GameState
    let board: Board
    let matchDetector = MatchDetector()
    let boardFiller = BoardFiller()
    private let specialResolver = SpecialGemResolver()
    private let blockerManager = BlockerManager()
    private let scoreCalculator = ScoreCalculator()
    private let objectiveTracker = ObjectiveTracker()
    private let mineBlast = MineBlast()
    let boosterManager = BoosterManager()

    /// The position of the gem the player actually moved (for special placement)
    private var playerSwapPos: GridPosition?

    init(state: GameState) {
        self.state = state
        self.board = state.board
    }

    // MARK: - Main Swap Handler

    func handleSwap(from posA: GridPosition, to posB: GridPosition) -> [GameEvent] {
        guard GridPosition.isAdjacent(posA, posB) else { return [] }
        guard board[posA] != nil, board[posB] != nil else { return [] }
        guard board.isPlayable(posA), board.isPlayable(posB) else { return [] }

        if board.blockerAt(posA) != nil {
            return [.invalidSwap(from: posA, to: posB)]
        }
        if board.blockerAt(posB) != nil {
            return [.invalidSwap(from: posA, to: posB)]
        }

        let gemA = board[posA]!
        let gemB = board[posB]!

        // Two specials swapped together
        if gemA.special != .none && gemB.special != .none {
            return handleSpecialCombo(posA: posA, posB: posB, gemA: gemA, gemB: gemB)
        }

        // Crystal ball swap
        if gemA.special == .crystalBall { return handleCrystalBallSwap(crystalPos: posA, targetPos: posB) }
        if gemB.special == .crystalBall { return handleCrystalBallSwap(crystalPos: posB, targetPos: posA) }

        // Any special gem swapped with a normal gem → activate immediately
        if gemA.special != .none || gemB.special != .none {
            return handleSpecialSwap(posA: posA, posB: posB, gemA: gemA, gemB: gemB)
        }

        // Normal swap
        board.swapGems(posA, posB)
        let matches = matchDetector.detectMatches(on: board)

        if matches.isEmpty {
            board.swapGems(posA, posB)
            return [.invalidSwap(from: posA, to: posB)]
        }

        var events: [GameEvent] = [.swap(from: posA, to: posB)]
        state.decrementMoves()
        playerSwapPos = posB  // posB is where posA's gem moved TO
        events.append(contentsOf: processCascade())
        playerSwapPos = nil
        events.append(contentsOf: processEndOfTurn())

        // Shuffle levels: shuffle all gems after every 3rd move
        if state.isShuffleLevel && state.movesMade % 3 == 0 && !state.isComplete && !state.isFailed {
            shuffleBoard()
            events.append(.boardShuffled)
        }

        return events
    }

    private func shuffleBoard() {
        var gems: [Gem] = []
        var positions: [GridPosition] = []
        for row in 0..<board.numRows {
            for col in 0..<board.numColumns {
                let pos = GridPosition(row: row, column: col)
                guard board.isPlayable(pos), let gem = board[pos], gem.special == .none else { continue }
                gems.append(gem)
                positions.append(pos)
            }
        }
        gems.shuffle()
        for (i, pos) in positions.enumerated() {
            var gem = gems[i]
            gem.row = pos.row
            gem.column = pos.column
            board.setGem(gem, at: pos)
        }
    }

    // MARK: - Cascade (reference algorithm Section 5)

    func processCascade() -> [GameEvent] {
        var events: [GameEvent] = []
        var chainIndex = 0

        var cascadeRound = 0
        let maxCascadeRounds = 50
        while cascadeRound < maxCascadeRounds {
            cascadeRound += 1
            let matches = matchDetector.detectMatches(on: board)
            if matches.isEmpty { break }

            // 1. Classify matches and determine specials
            var allMatchedPositions = Set<GridPosition>()
            var specialsToCreate: [(SpecialType, GemColor, GridPosition)] = []

            for match in matches {
                allMatchedPositions.formUnion(match.positions)

                if let specialType = match.specialType, let specialPos = match.specialPosition {
                    // Special appears at PLAYER'S swap position if this is the first cascade
                    // and the swap position is part of this match
                    let pos: GridPosition
                    if chainIndex == 0, let swapPos = playerSwapPos,
                       match.positions.contains(swapPos) {
                        pos = swapPos
                    } else {
                        pos = specialPos
                    }
                    specialsToCreate.append((specialType, match.color, pos))
                }
            }

            let specialPositions = Set(specialsToCreate.map { $0.2 })

            // 2. Emit match removal (exclude positions where specials will be created)
            events.append(.matched(positions: allMatchedPositions.subtracting(specialPositions), chainIndex: chainIndex))

            // 3. Process blockers adjacent to matches
            events.append(contentsOf: blockerManager.processMatchAdjacent(
                matchedPositions: allMatchedPositions, on: board
            ))

            // 4. Track objectives
            events.append(contentsOf: objectiveTracker.processMatch(
                positions: allMatchedPositions, on: board, state: state
            ))

            // 5. Activate special gems that were in the matched set (CHAIN REACTION)
            var activatedPositions = Set<GridPosition>()
            var positionsToActivate = Array(allMatchedPositions)
            var activationRound = 0

            while !positionsToActivate.isEmpty && activationRound < 10 {
                var nextRound: [GridPosition] = []

                for pos in positionsToActivate {
                    guard let gem = board[pos], gem.special != .none,
                          !specialPositions.contains(pos),
                          !activatedPositions.contains(pos) else { continue }

                    activatedPositions.insert(pos)
                    let affected: Set<GridPosition>
                    if gem.special == .crystalBall {
                        // Crystal ball hit by chain: activate with a neighbor color
                        let neighborColors = pos.neighbors.compactMap { board[$0]?.color }
                        let targetColor = neighborColors.randomElement() ?? gem.color
                        affected = specialResolver.resolveCrystalBall(targetColor: targetColor, on: board)
                    } else {
                        affected = specialResolver.resolve(special: gem.special, at: pos, on: board)
                    }
                    if !affected.isEmpty {
                        events.append(.specialActivated(type: gem.special, at: pos, affected: affected))
                        let delta = scoreCalculator.scoreForSpecialActivation(gem.special)
                        state.score += delta
                        events.append(.scoreUpdated(newScore: state.score, delta: delta, at: pos))

                        // Chain reaction: newly affected positions may contain specials
                        for affectedPos in affected {
                            allMatchedPositions.insert(affectedPos)
                            if !activatedPositions.contains(affectedPos) {
                                nextRound.append(affectedPos)
                            }
                        }
                    }
                }

                positionsToActivate = nextRound
                activationRound += 1
            }

            // 5b. Process blockers adjacent to chain-reaction affected positions
            if !activatedPositions.isEmpty {
                let chainAffected = allMatchedPositions.subtracting(allMatchedPositions.intersection(
                    matches.flatMap { $0.positions }
                ))
                if !chainAffected.isEmpty {
                    events.append(contentsOf: blockerManager.processMatchAdjacent(
                        matchedPositions: chainAffected, on: board
                    ))
                }
            }

            // 6. Score the matches
            for match in matches {
                let delta = scoreCalculator.scoreForMatch(match, chainIndex: chainIndex)
                state.score += delta
                if let centerPos = match.positions.first {
                    events.append(.scoreUpdated(newScore: state.score, delta: delta, at: centerPos))
                }
            }

            // 7. Remove all matched gems except special creation positions
            for pos in allMatchedPositions {
                if !specialPositions.contains(pos) {
                    board.removeGem(at: pos)
                }
            }

            // 8. Create special gems (with MATCH COLOR, not position color)
            for (specialType, color, pos) in specialsToCreate {
                board.removeGem(at: pos)
                let gem = Gem(color: color, special: specialType, row: pos.row, column: pos.column)
                board.setGem(gem, at: pos)
                events.append(.specialCreated(type: specialType, color: color, at: pos))
            }

            // 9. Gravity + spawn
            let (falls, newGems) = boardFiller.dropAndFill(board: board, numColors: state.level.effectiveNumColors)
            if !falls.isEmpty { events.append(.gemsFell(moves: falls)) }
            if !newGems.isEmpty { events.append(.gemsAdded(gems: newGems)) }

            events.append(contentsOf: objectiveTracker.checkTreasureDrops(on: board, state: state))

            chainIndex += 1
        }

        return events
    }

    // MARK: - Special Swap (laser/volatile/drone + normal gem)

    private func handleSpecialSwap(posA: GridPosition, posB: GridPosition,
                                    gemA: Gem, gemB: Gem) -> [GameEvent] {
        var events: [GameEvent] = [.swap(from: posA, to: posB)]
        state.decrementMoves()
        board.swapGems(posA, posB)

        let specialPos = gemA.special != .none ? posB : posA
        let specialGem = gemA.special != .none ? gemA : gemB

        if specialGem.special == .miningDrone {
            let targets = specialResolver.getDroneTargets(count: 3, on: board, prioritizeOre: true)
            for target in targets {
                events.append(.droneDeployed(from: specialPos, to: target))
                if let blocker = board.blockerAt(target) {
                    switch blocker {
                    case .granite(let layers):
                        if layers > 1 {
                            board.setBlocker(.granite(layers: layers - 1), at: target)
                            events.append(.blockerDamaged(at: target, type: blocker))
                        } else {
                            board.setBlocker(nil, at: target)
                            events.append(.blockerDestroyed(at: target))
                        }
                    default:
                        board.setBlocker(nil, at: target)
                        events.append(.blockerDestroyed(at: target))
                    }
                }
                board.removeGem(at: target)
                state.score += 60
            }
            board.removeGem(at: specialPos)
        } else {
            let affected = specialResolver.resolve(special: specialGem.special, at: specialPos, on: board)
            if !affected.isEmpty {
                events.append(.specialActivated(type: specialGem.special, at: specialPos, affected: affected))
                let delta = scoreCalculator.scoreForSpecialActivation(specialGem.special)
                state.score += delta
                events.append(.scoreUpdated(newScore: state.score, delta: delta, at: specialPos))
                board.removeGem(at: specialPos)
                for pos in affected { board.removeGem(at: pos) }
                events.append(contentsOf: blockerManager.processMatchAdjacent(
                    matchedPositions: Set(affected), on: board
                ))
            }
        }

        let (falls, newGems) = boardFiller.dropAndFill(board: board, numColors: state.level.effectiveNumColors)
        if !falls.isEmpty { events.append(.gemsFell(moves: falls)) }
        if !newGems.isEmpty { events.append(.gemsAdded(gems: newGems)) }
        events.append(contentsOf: processCascade())
        events.append(contentsOf: processEndOfTurn())
        return events
    }

    // MARK: - Crystal Ball

    private func handleCrystalBallSwap(crystalPos: GridPosition, targetPos: GridPosition) -> [GameEvent] {
        var events: [GameEvent] = [.swap(from: crystalPos, to: targetPos)]
        state.decrementMoves()

        guard let targetGem = board[targetPos] else { return events }

        if targetGem.special != .none && targetGem.special != .crystalBall {
            return handleCrystalBallSpecialCombo(crystalPos: crystalPos, targetPos: targetPos, events: events)
        }

        let affected = specialResolver.resolveCrystalBall(targetColor: targetGem.color, on: board)
        events.append(.specialActivated(type: .crystalBall, at: crystalPos, affected: affected))

        let delta = scoreCalculator.scoreForSpecialActivation(.crystalBall)
        state.score += delta
        events.append(.scoreUpdated(newScore: state.score, delta: delta, at: crystalPos))

        board.removeGem(at: crystalPos)
        for pos in affected { board.removeGem(at: pos) }
        events.append(contentsOf: blockerManager.processMatchAdjacent(
            matchedPositions: Set(affected), on: board
        ))

        let (falls, newGems) = boardFiller.dropAndFill(board: board, numColors: state.level.effectiveNumColors)
        if !falls.isEmpty { events.append(.gemsFell(moves: falls)) }
        if !newGems.isEmpty { events.append(.gemsAdded(gems: newGems)) }
        events.append(contentsOf: processCascade())
        events.append(contentsOf: processEndOfTurn())
        return events
    }

    /// Crystal Ball + Special Gem: replicate that special across all gems of target color
    /// For lasers: 50% horizontal, 50% vertical
    private func handleCrystalBallSpecialCombo(crystalPos: GridPosition, targetPos: GridPosition, events: [GameEvent]) -> [GameEvent] {
        var events = events
        guard let targetGem = board[targetPos] else { return events }

        let targetColor = targetGem.color
        let targetSpecial = targetGem.special

        var colorPositions: [GridPosition] = []
        for pos in board.allPlayablePositions() {
            if let gem = board[pos], gem.color == targetColor, pos != crystalPos, pos != targetPos {
                colorPositions.append(pos)
            }
        }

        board.removeGem(at: crystalPos)
        board.removeGem(at: targetPos)

        // Convert all gems of that color to the special type
        for (i, pos) in colorPositions.enumerated() {
            if var gem = board[pos] {
                var assignedSpecial = targetSpecial
                // For laser specials: alternate 50% horizontal / 50% vertical
                if targetSpecial == .laserHorizontal || targetSpecial == .laserVertical {
                    assignedSpecial = (i % 2 == 0) ? .laserHorizontal : .laserVertical
                }
                gem.special = assignedSpecial
                board.setGem(gem, at: pos)
                events.append(.specialCreated(type: assignedSpecial, color: targetColor, at: pos))
            }
        }

        // Activate all converted specials
        var allAffected = Set<GridPosition>([crystalPos, targetPos])
        for pos in colorPositions {
            if let gem = board[pos], gem.special != .none {
                let affected = specialResolver.resolve(special: gem.special, at: pos, on: board)
                if !affected.isEmpty {
                    events.append(.specialActivated(type: gem.special, at: pos, affected: affected))
                    allAffected.formUnion(affected)
                }
                board.removeGem(at: pos)
            }
        }
        for pos in allAffected { board.removeGem(at: pos) }
        events.append(contentsOf: blockerManager.processMatchAdjacent(
            matchedPositions: Set(allAffected), on: board
        ))

        let delta = scoreCalculator.scoreForSpecialActivation(.crystalBall) * 3
        state.score += delta
        events.append(.scoreUpdated(newScore: state.score, delta: delta, at: crystalPos))

        let (falls, newGems) = boardFiller.dropAndFill(board: board, numColors: state.level.effectiveNumColors)
        if !falls.isEmpty { events.append(.gemsFell(moves: falls)) }
        if !newGems.isEmpty { events.append(.gemsAdded(gems: newGems)) }
        events.append(contentsOf: processCascade())
        events.append(contentsOf: processEndOfTurn())
        return events
    }

    // MARK: - Special + Special Combo

    private func handleSpecialCombo(posA: GridPosition, posB: GridPosition,
                                     gemA: Gem, gemB: Gem) -> [GameEvent] {
        var events: [GameEvent] = [.swap(from: posA, to: posB)]
        state.decrementMoves()
        board.swapGems(posA, posB)

        // Crystal Ball + Crystal Ball = clear ENTIRE board, guarantee specials in refill
        if gemA.special == .crystalBall && gemB.special == .crystalBall {
            let allPositions = board.allPlayablePositions().filter { board[$0] != nil }
            events.append(.specialActivated(type: .crystalBall, at: posA, affected: Set(allPositions)))

            for pos in allPositions { board.removeGem(at: pos) }

            // Also damage/clear all blockers on the board
            for pos in board.allPlayablePositions() {
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
                default:
                    board.setBlocker(nil, at: pos)
                    events.append(.blockerDestroyed(at: pos))
                }
            }

            let delta = scoreCalculator.scoreForSpecialActivation(.crystalBall) * 5
            state.score += delta
            events.append(.scoreUpdated(newScore: state.score, delta: delta, at: posA))

            // Refill with guaranteed specials
            let (falls, newGems) = boardFiller.dropAndFill(board: board, numColors: state.level.effectiveNumColors)
            if !falls.isEmpty { events.append(.gemsFell(moves: falls)) }
            if !newGems.isEmpty { events.append(.gemsAdded(gems: newGems)) }

            // Place one of each special gem on the new board
            let specials: [SpecialType] = [.laserHorizontal, .laserVertical, .volatile, .miningDrone]
            let candidates = board.allPlayablePositions().filter { pos in
                guard let gem = board[pos] else { return false }
                return gem.special == .none
            }.shuffled()
            for (i, special) in specials.enumerated() {
                if i < candidates.count, var gem = board[candidates[i]] {
                    gem.special = special
                    board.setGem(gem, at: candidates[i])
                    events.append(.specialCreated(type: special, color: gem.color, at: candidates[i]))
                }
            }

            events.append(contentsOf: processCascade())
            events.append(contentsOf: processEndOfTurn())
            return events
        }

        // Crystal Ball + other special
        if gemA.special == .crystalBall || gemB.special == .crystalBall {
            let crystalPos = gemA.special == .crystalBall ? posB : posA
            let otherPos = gemA.special == .crystalBall ? posA : posB
            board.swapGems(posA, posB)
            return handleCrystalBallSwap(crystalPos: crystalPos, targetPos: otherPos)
        }

        var affected = specialResolver.resolveCombo(
            specialA: gemA.special, posA: posA, specialB: gemB.special, posB: posB, on: board
        )
        events.append(.specialActivated(type: gemA.special, at: posA, affected: affected))

        let delta = scoreCalculator.scoreForSpecialActivation(gemA.special) +
                    scoreCalculator.scoreForSpecialActivation(gemB.special)
        state.score += delta
        events.append(.scoreUpdated(newScore: state.score, delta: delta, at: posA))

        // Chain-activate any special gems hit by the combo
        var activated = Set<GridPosition>([posA, posB])
        var toActivate = affected.filter { pos in
            guard let gem = board[pos], gem.special != .none, !activated.contains(pos) else { return false }
            return true
        }
        var chainRound = 0
        while !toActivate.isEmpty && chainRound < 10 {
            var nextRound = Set<GridPosition>()
            for pos in toActivate {
                guard let gem = board[pos], gem.special != .none, !activated.contains(pos) else { continue }
                activated.insert(pos)

                if gem.special == .crystalBall {
                    // Crystal ball: pick a color from neighbors
                    let neighborColors = pos.neighbors.compactMap { board[$0]?.color }
                    let targetColor = neighborColors.randomElement() ?? .ruby
                    let cbAffected = specialResolver.resolveCrystalBall(targetColor: targetColor, on: board)
                    events.append(.specialActivated(type: .crystalBall, at: pos, affected: cbAffected))
                    affected.formUnion(cbAffected)
                    for p in cbAffected where !activated.contains(p) {
                        if let g = board[p], g.special != .none { nextRound.insert(p) }
                    }
                } else {
                    let specialAffected = specialResolver.resolve(special: gem.special, at: pos, on: board)
                    if !specialAffected.isEmpty {
                        events.append(.specialActivated(type: gem.special, at: pos, affected: specialAffected))
                        affected.formUnion(specialAffected)
                        for p in specialAffected where !activated.contains(p) {
                            if let g = board[p], g.special != .none { nextRound.insert(p) }
                        }
                    }
                }

                let chainDelta = scoreCalculator.scoreForSpecialActivation(gem.special)
                state.score += chainDelta
                events.append(.scoreUpdated(newScore: state.score, delta: chainDelta, at: pos))
            }
            toActivate = nextRound
            chainRound += 1
        }

        board.removeGem(at: posA)
        board.removeGem(at: posB)
        for pos in affected { board.removeGem(at: pos) }

        events.append(contentsOf: blockerManager.processMatchAdjacent(matchedPositions: affected, on: board))

        let (falls, newGems) = boardFiller.dropAndFill(board: board, numColors: state.level.effectiveNumColors)
        if !falls.isEmpty { events.append(.gemsFell(moves: falls)) }
        if !newGems.isEmpty { events.append(.gemsAdded(gems: newGems)) }
        events.append(contentsOf: processCascade())
        events.append(contentsOf: processEndOfTurn())
        return events
    }

    // MARK: - End of Turn

    private func processEndOfTurn() -> [GameEvent] {
        var events: [GameEvent] = []
        let blockerEvents = blockerManager.processEndOfTurn(on: board)
        events.append(contentsOf: blockerEvents)

        if blockerManager.hasTNTExploded(events: blockerEvents) {
            state.isFailed = true; events.append(.levelFailed); return events
        }

        if !matchDetector.hasAnyValidMove(on: board) {
            boardFiller.shuffle(board: board)
            events.append(.boardShuffled)
        }

        if state.checkObjectives() {
            state.isComplete = true
            events.append(contentsOf: mineBlast.execute(state: state, board: board))
            events.append(.levelComplete(stars: state.starRating, score: state.score))
            return events
        }

        if state.movesRemaining <= 0 && !state.godModeEnabled {
            state.isFailed = true; events.append(.levelFailed)
        }
        return events
    }

    // MARK: - Board Initialization

    func initializeBoard() -> [GameEvent] {
        boardFiller.initialFill(board: board, numColors: state.level.effectiveNumColors)
        return processCascade()
    }

    func initializeBoard(seed: UInt64) -> [GameEvent] {
        boardFiller.initialFill(board: board, numColors: state.level.effectiveNumColors, seed: seed)
        return processCascade()
    }
}
