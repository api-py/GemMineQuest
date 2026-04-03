import Foundation

class GameEngine {

    let state: GameState
    let board: Board
    private let matchDetector = MatchDetector()
    private let boardFiller = BoardFiller()
    private let specialResolver = SpecialGemResolver()
    private let blockerManager = BlockerManager()
    private let scoreCalculator = ScoreCalculator()
    private let objectiveTracker = ObjectiveTracker()
    private let mineBlast = MineBlast()
    let boosterManager = BoosterManager()

    init(state: GameState) {
        self.state = state
        self.board = state.board
    }

    // MARK: - Main Swap Handler

    /// Handle a player swap. Returns all events for animation.
    func handleSwap(from posA: GridPosition, to posB: GridPosition) -> [GameEvent] {
        guard GridPosition.isAdjacent(posA, posB) else { return [] }
        guard board[posA] != nil, board[posB] != nil else { return [] }
        guard board.isPlayable(posA), board.isPlayable(posB) else { return [] }

        // Check for caged gems - can't move them
        if case .cage = board.blockerAt(posA) { return [.invalidSwap(from: posA, to: posB)] }
        if case .cage = board.blockerAt(posB) { return [.invalidSwap(from: posA, to: posB)] }
        if case .amber = board.blockerAt(posA) { return [.invalidSwap(from: posA, to: posB)] }
        if case .amber = board.blockerAt(posB) { return [.invalidSwap(from: posA, to: posB)] }

        var events: [GameEvent] = []

        let gemA = board[posA]!
        let gemB = board[posB]!

        // Check for special + special combo
        if gemA.special != .none && gemB.special != .none {
            return handleSpecialCombo(posA: posA, posB: posB, gemA: gemA, gemB: gemB)
        }

        // Check for crystal ball swap (crystal ball + any gem)
        if gemA.special == .crystalBall {
            return handleCrystalBallSwap(crystalPos: posA, targetPos: posB)
        }
        if gemB.special == .crystalBall {
            return handleCrystalBallSwap(crystalPos: posB, targetPos: posA)
        }

        // Try the swap
        board.swapGems(posA, posB)

        let matches = matchDetector.detectMatches(on: board)

        if matches.isEmpty {
            // Invalid swap - revert
            board.swapGems(posA, posB)
            return [.invalidSwap(from: posA, to: posB)]
        }

        // Valid swap
        events.append(.swap(from: posA, to: posB))
        state.decrementMoves()

        // Process cascade
        events.append(contentsOf: processCascade(initialSwapPos: posA))

        // End of turn processing
        events.append(contentsOf: processEndOfTurn())

        return events
    }

    // MARK: - Cascade Processing

    private func processCascade(initialSwapPos: GridPosition? = nil) -> [GameEvent] {
        var events: [GameEvent] = []
        var chainIndex = 0

        while true {
            let matches = matchDetector.detectMatches(on: board)
            if matches.isEmpty { break }

            // Process all matches in this cascade step
            var allMatchedPositions = Set<GridPosition>()
            var specialsToCreate: [(SpecialType, GemColor, GridPosition)] = []

            for match in matches {
                allMatchedPositions.formUnion(match.positions)

                // Determine special gem creation
                if let specialType = match.specialType, let specialPos = match.specialPosition {
                    // For initial swap, place special where the player moved
                    let pos = (chainIndex == 0 && initialSwapPos != nil && match.positions.contains(initialSwapPos!))
                        ? initialSwapPos! : specialPos
                    specialsToCreate.append((specialType, match.color, pos))
                }
            }

            // Match event
            events.append(.matched(positions: allMatchedPositions, chainIndex: chainIndex))

            // Process blockers adjacent to matches
            let blockerEvents = blockerManager.processMatchAdjacent(
                matchedPositions: allMatchedPositions, on: board
            )
            events.append(contentsOf: blockerEvents)

            // Track objectives
            let objEvents = objectiveTracker.processMatch(
                positions: allMatchedPositions, on: board, state: state
            )
            events.append(contentsOf: objEvents)

            // Activate any special gems that were matched
            for pos in allMatchedPositions {
                if let gem = board[pos], gem.special != .none && gem.special != .crystalBall {
                    let affected = specialResolver.resolve(special: gem.special, at: pos, on: board)
                    if !affected.isEmpty {
                        events.append(.specialActivated(type: gem.special, at: pos, affected: affected))
                        // Remove affected gems (excluding already matched)
                        for affectedPos in affected {
                            if !allMatchedPositions.contains(affectedPos) {
                                allMatchedPositions.insert(affectedPos)
                            }
                        }
                    }
                }
            }

            // Calculate score
            for match in matches {
                let delta = scoreCalculator.scoreForMatch(match, chainIndex: chainIndex)
                state.score += delta
                if let centerPos = match.positions.first {
                    events.append(.scoreUpdated(newScore: state.score, delta: delta, at: centerPos))
                }
            }

            // Remove matched gems (but keep positions for special gem creation)
            for pos in allMatchedPositions {
                if !specialsToCreate.contains(where: { $0.2 == pos }) {
                    board.removeGem(at: pos)
                }
            }

            // Create special gems
            for (specialType, color, pos) in specialsToCreate {
                let gem = Gem(color: color, special: specialType, row: pos.row, column: pos.column)
                board.setGem(gem, at: pos)
                events.append(.specialCreated(type: specialType, color: color, at: pos))
            }

            // Drop and fill
            let (falls, newGems) = boardFiller.dropAndFill(
                board: board, numColors: state.level.effectiveNumColors
            )
            if !falls.isEmpty {
                events.append(.gemsFell(moves: falls))
            }
            if !newGems.isEmpty {
                events.append(.gemsAdded(gems: newGems))
            }

            // Check treasure drops
            let treasureEvents = objectiveTracker.checkTreasureDrops(on: board, state: state)
            events.append(contentsOf: treasureEvents)

            chainIndex += 1

            // Safety: prevent infinite cascades
            if chainIndex > 50 { break }
        }

        return events
    }

    // MARK: - Special Handlers

    private func handleCrystalBallSwap(crystalPos: GridPosition, targetPos: GridPosition) -> [GameEvent] {
        var events: [GameEvent] = [.swap(from: crystalPos, to: targetPos)]
        state.decrementMoves()

        guard let targetGem = board[targetPos] else { return events }

        let affected = specialResolver.resolveCrystalBall(targetColor: targetGem.color, on: board)
        events.append(.specialActivated(type: .crystalBall, at: crystalPos, affected: affected))

        let delta = scoreCalculator.scoreForSpecialActivation(.crystalBall)
        state.score += delta
        events.append(.scoreUpdated(newScore: state.score, delta: delta, at: crystalPos))

        // Remove crystal ball and all affected gems
        board.removeGem(at: crystalPos)
        for pos in affected {
            board.removeGem(at: pos)
        }

        // Track objectives
        let objEvents = objectiveTracker.processMatch(positions: affected.union([crystalPos]), on: board, state: state)
        events.append(contentsOf: objEvents)

        // Drop and fill, then cascade
        let (falls, newGems) = boardFiller.dropAndFill(board: board, numColors: state.level.effectiveNumColors)
        if !falls.isEmpty { events.append(.gemsFell(moves: falls)) }
        if !newGems.isEmpty { events.append(.gemsAdded(gems: newGems)) }

        events.append(contentsOf: processCascade())
        events.append(contentsOf: processEndOfTurn())

        return events
    }

    private func handleSpecialCombo(posA: GridPosition, posB: GridPosition,
                                     gemA: Gem, gemB: Gem) -> [GameEvent] {
        var events: [GameEvent] = [.swap(from: posA, to: posB)]
        state.decrementMoves()

        board.swapGems(posA, posB)

        let affected = specialResolver.resolveCombo(
            specialA: gemA.special, posA: posA,
            specialB: gemB.special, posB: posB,
            on: board
        )

        let comboType = gemA.special // Use first special for event
        events.append(.specialActivated(type: comboType, at: posA, affected: affected))

        // Score
        let deltaA = scoreCalculator.scoreForSpecialActivation(gemA.special)
        let deltaB = scoreCalculator.scoreForSpecialActivation(gemB.special)
        state.score += deltaA + deltaB
        events.append(.scoreUpdated(newScore: state.score, delta: deltaA + deltaB, at: posA))

        // Remove affected gems
        board.removeGem(at: posA)
        board.removeGem(at: posB)
        for pos in affected {
            board.removeGem(at: pos)
        }

        // Process blockers
        let blockerEvents = blockerManager.processMatchAdjacent(matchedPositions: affected, on: board)
        events.append(contentsOf: blockerEvents)

        // Track objectives
        let objEvents = objectiveTracker.processMatch(positions: affected.union([posA, posB]), on: board, state: state)
        events.append(contentsOf: objEvents)

        // Drop, fill, cascade
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

        // Process blockers (lava spread, TNT countdown)
        let blockerEvents = blockerManager.processEndOfTurn(on: board)
        events.append(contentsOf: blockerEvents)

        // Check TNT explosion (game over)
        if blockerManager.hasTNTExploded(events: blockerEvents) {
            state.isFailed = true
            events.append(.levelFailed)
            return events
        }

        // Check deadlock
        if !matchDetector.hasAnyValidMove(on: board) {
            boardFiller.shuffle(board: board)
            events.append(.boardShuffled)
        }

        // Check win condition
        if state.checkObjectives() {
            state.isComplete = true

            // Mine Blast bonus
            let blastEvents = mineBlast.execute(state: state, board: board)
            events.append(contentsOf: blastEvents)

            events.append(.levelComplete(stars: state.starRating, score: state.score))
            return events
        }

        // Check lose condition (out of moves)
        if state.movesRemaining <= 0 && !state.godModeEnabled {
            state.isFailed = true
            events.append(.levelFailed)
        }

        return events
    }

    // MARK: - Board Initialization

    func initializeBoard() -> [GameEvent] {
        boardFiller.initialFill(board: board, numColors: state.level.effectiveNumColors)
        return []
    }

    func initializeBoard(seed: UInt64) -> [GameEvent] {
        boardFiller.initialFill(board: board, numColors: state.level.effectiveNumColors, seed: seed)
        return []
    }
}
