import Foundation

/// Handles the end-of-level bonus (Sugar Crush equivalent).
/// When a level is completed with remaining moves, those moves convert to laser gems
/// and all specials on the board activate in sequence.
class MineBlast {

    private let scoreCalculator = ScoreCalculator()

    /// Execute Mine Blast sequence. Returns events for animation.
    func execute(state: GameState, board: Board) -> [GameEvent] {
        guard state.movesRemaining > 0 && !state.godModeEnabled else { return [] }

        var events: [GameEvent] = [.mineBlastStarted]

        // 1. Convert remaining moves to laser gems
        let movesToConvert = Int(Double(state.movesRemaining) * Constants.mineBlastMovesToStriped)
        let emptyPlayable = board.allPlayablePositions().filter { board[$0] != nil && board[$0]?.special == SpecialType.none }
        let convertPositions = emptyPlayable.shuffled().prefix(movesToConvert)

        for pos in convertPositions {
            if var gem = board[pos] {
                let direction: SpecialType = Bool.random() ? .laserHorizontal : .laserVertical
                gem.special = direction
                board.setGem(gem, at: pos)
                events.append(.mineBlastConvertedMove(at: pos))
            }
        }

        // 2. Collect all specials on board for scoring
        let specials = board.allGems()
            .filter { $0.special != .none }
            .map { ($0.special, $0.position) }

        // 3. Calculate bonus
        let bonusScore = scoreCalculator.mineBlastScore(
            remainingMoves: state.movesRemaining,
            specialsOnBoard: specials
        )

        state.score += bonusScore
        events.append(.mineBlastFinished(bonusScore: bonusScore))

        return events
    }
}
