import XCTest
@testable import GemMineQuest

@MainActor
final class CascadeTests: XCTestCase {

    /// After initializeBoard, there must be ZERO matches remaining
    func testInitializeBoardLeavesNoMatches() {
        for seed in [1, 42, 100, 999, 12345, 77777] as [UInt64] {
            let level = Level(
                number: 1, maxMoves: 20,
                objectives: [.reachScore(target: 100)],
                targetScores: [100, 200, 300],
                tileLayout: Array(repeating: Array(repeating: 1, count: Constants.defaultGridColumns), count: Constants.defaultGridRows),
                blockerLayout: nil, treasureColumns: nil, numColors: 6
            )
            let board = level.buildBoard()
            let state = GameState(level: level, board: board)
            let engine = GameEngine(state: state)

            let _ = engine.initializeBoard(seed: seed)

            // Check NO matches remain
            let matches = engine.matchDetector.detectMatches(on: board)
            if !matches.isEmpty {
                // Print debug info
                for match in matches {
                    print("REMAINING MATCH at seed \(seed): \(match.positions) color=\(match.color)")
                    for pos in match.positions {
                        print("  board[\(pos)] = \(String(describing: board[pos]?.color))")
                    }
                }
            }
            XCTAssertTrue(matches.isEmpty,
                "Seed \(seed): \(matches.count) matches remain after initializeBoard! First: \(matches.first?.positions ?? [])")
        }
    }

    /// After a valid swap, there must be ZERO matches remaining
    func testSwapLeavesNoMatches() {
        let level = Level(
            number: 1, maxMoves: 50,
            objectives: [.reachScore(target: 100)],
            targetScores: [100, 200, 300],
            tileLayout: Array(repeating: Array(repeating: 1, count: Constants.defaultGridColumns), count: Constants.defaultGridRows),
            blockerLayout: nil, treasureColumns: nil, numColors: 5
        )
        let board = level.buildBoard()
        let state = GameState(level: level, board: board)
        state.godModeEnabled = true
        let engine = GameEngine(state: state)
        engine.initializeBoard(seed: 42)

        // Try up to 20 valid swaps
        var swapsFound = 0
        for row in 0..<board.numRows {
            for col in 0..<board.numColumns {
                guard swapsFound < 20 else { break }
                let pos = GridPosition(row: row, column: col)
                let right = GridPosition(row: row, column: col + 1)
                if board.isValidPosition(right) && board[pos] != nil && board[right] != nil {
                    if engine.matchDetector.wouldMatch(board: board, swapping: pos, with: right) {
                        let _ = engine.handleSwap(from: pos, to: right)
                        swapsFound += 1

                        let matches = engine.matchDetector.detectMatches(on: board)
                        XCTAssertTrue(matches.isEmpty,
                            "After swap \(swapsFound): \(matches.count) matches remain")

                        // Also check no empty playable cells
                        for p in board.allPlayablePositions() {
                            XCTAssertNotNil(board[p], "Gap at \(p) after swap \(swapsFound)")
                        }
                    }
                }
            }
        }
        XCTAssertGreaterThan(swapsFound, 0, "Should have found at least one valid swap")
    }

    /// Gravity must leave no empty playable cells
    func testGravityFillsAllGaps() {
        let board = Board()
        let filler = BoardFiller()
        filler.initialFill(board: board, numColors: 6, seed: 42)

        // Remove a large chunk
        for row in 0..<4 {
            for col in 0..<4 {
                board.removeGem(at: GridPosition(row: row, column: col))
            }
        }

        let _ = filler.dropAndFill(board: board)

        for pos in board.allPlayablePositions() {
            XCTAssertNotNil(board[pos], "Gap at \(pos) after dropAndFill")
        }
    }
}
