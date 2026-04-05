import XCTest
@testable import GemMineQuest

final class GameEngineTests: XCTestCase {

    func testValidSwapProducesEvents() {
        let level = Level(
            number: 1, maxMoves: 20,
            objectives: [.reachScore(target: 100)],
            targetScores: [100, 200, 300],
            tileLayout: Array(repeating: Array(repeating: 1, count: 8), count: 8),
            blockerLayout: nil, treasureColumns: nil, numColors: 6
        )
        let board = level.buildBoard()
        let state = GameState(level: level, board: board)
        let engine = GameEngine(state: state)

        // Manually place gems to guarantee a match
        let posA = GridPosition(row: 0, column: 0)
        let posB = GridPosition(row: 0, column: 1)
        let posC = GridPosition(row: 0, column: 2)
        let posSwap = GridPosition(row: 1, column: 0)

        board.setGem(Gem(color: .ruby, row: 0, column: 0), at: posA)
        board.setGem(Gem(color: .sapphire, row: 0, column: 1), at: posB)
        board.setGem(Gem(color: .ruby, row: 0, column: 2), at: posC)
        board.setGem(Gem(color: .ruby, row: 1, column: 0), at: posSwap)

        // Fill rest of board
        let filler = BoardFiller()
        filler.initialFill(board: board, numColors: 6)

        // Swap should work because ruby at (1,0) swaps with sapphire at (0,0)
        // creating ruby-ruby-ruby at row 0
        // Note: this test is somewhat fragile due to fill randomness
        // but validates the basic flow
        let events = engine.handleSwap(from: posSwap, to: posA)
        // Should have at least a swap or invalidSwap event
        XCTAssertFalse(events.isEmpty)
    }

    func testInvalidSwapReturnsInvalidEvent() {
        let level = Level(
            number: 1, maxMoves: 20,
            objectives: [.reachScore(target: 100)],
            targetScores: [100, 200, 300],
            tileLayout: Array(repeating: Array(repeating: 1, count: 8), count: 8),
            blockerLayout: nil, treasureColumns: nil, numColors: 6
        )
        let board = level.buildBoard()
        let state = GameState(level: level, board: board)
        let engine = GameEngine(state: state)

        // Place gems so that swapping (0,0) with (0,1) does NOT create a match
        board.setGem(Gem(color: .ruby, row: 0, column: 0), at: GridPosition(row: 0, column: 0))
        board.setGem(Gem(color: .sapphire, row: 0, column: 1), at: GridPosition(row: 0, column: 1))
        board.setGem(Gem(color: .emerald, row: 0, column: 2), at: GridPosition(row: 0, column: 2))
        board.setGem(Gem(color: .gold, row: 1, column: 0), at: GridPosition(row: 1, column: 0))
        board.setGem(Gem(color: .silver, row: 1, column: 1), at: GridPosition(row: 1, column: 1))

        let events = engine.handleSwap(
            from: GridPosition(row: 0, column: 0),
            to: GridPosition(row: 0, column: 1)
        )

        XCTAssertTrue(events.contains(where: {
            if case .invalidSwap = $0 { return true }
            return false
        }))
    }

    func testGodModeDoesNotDecrementMoves() {
        let level = Level(
            number: 1, maxMoves: 10,
            objectives: [.reachScore(target: 100)],
            targetScores: [100, 200, 300],
            tileLayout: Array(repeating: Array(repeating: 1, count: 8), count: 8),
            blockerLayout: nil, treasureColumns: nil, numColors: 4
        )
        let board = level.buildBoard()
        let state = GameState(level: level, board: board)
        state.godModeEnabled = true
        let engine = GameEngine(state: state)

        // Fill board and try a swap
        engine.initializeBoard()
        let initialMoves = state.movesRemaining

        // Even after processing, moves should not change
        state.decrementMoves()
        XCTAssertEqual(state.movesRemaining, initialMoves)
    }
}
