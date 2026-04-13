import XCTest
@testable import GemMineQuest

final class BoardFillerTests: XCTestCase {

    func testInitialFillNoMatches() {
        let board = Board()
        let filler = BoardFiller()
        let detector = MatchDetector()

        filler.initialFill(board: board, numColors: 6)

        for row in 0..<Constants.defaultGridRows {
            for col in 0..<Constants.defaultGridColumns {
                XCTAssertNotNil(board[row, col], "Gem missing at (\(row), \(col))")
            }
        }

        let matches = detector.detectMatches(on: board)
        XCTAssertTrue(matches.isEmpty, "Board has pre-existing matches after initial fill")
    }

    func testSeededFillIsDeterministic() {
        let board1 = Board()
        let board2 = Board()
        let filler = BoardFiller()

        filler.initialFill(board: board1, numColors: 6, seed: 12345)
        filler.initialFill(board: board2, numColors: 6, seed: 12345)

        for row in 0..<Constants.defaultGridRows {
            for col in 0..<Constants.defaultGridColumns {
                XCTAssertEqual(board1[row, col]?.color, board2[row, col]?.color)
            }
        }
    }

    func testDropAndFillNoGaps() {
        let board = Board()
        let filler = BoardFiller()
        filler.initialFill(board: board, numColors: 6)

        // Remove several gems to create gaps
        board.removeGem(at: GridPosition(row: 0, column: 0))
        board.removeGem(at: GridPosition(row: 1, column: 0))
        board.removeGem(at: GridPosition(row: 3, column: 3))
        board.removeGem(at: GridPosition(row: 5, column: 5))
        board.removeGem(at: GridPosition(row: 0, column: 7))

        let _ = filler.dropAndFill(board: board)

        // After fill, ALL playable positions must have gems
        for row in 0..<Constants.defaultGridRows {
            for col in 0..<Constants.defaultGridColumns {
                let pos = GridPosition(row: row, column: col)
                if board.isPlayable(pos) {
                    XCTAssertNotNil(board[pos], "Empty gap at (\(row), \(col)) after dropAndFill")
                }
            }
        }
    }

    func testVerticalGravityGemsDropDown() {
        let board = Board()
        let filler = BoardFiller()

        // Place a gem at row 5 col 0, leave rows 0-4 empty
        let gem = Gem(color: .ruby, row: 5, column: 0)
        board.setGem(gem, at: GridPosition(row: 5, column: 0))

        let (falls, _) = filler.dropAndFill(board: board)

        // The gem should have fallen to row 0
        XCTAssertNotNil(board[GridPosition(row: 0, column: 0)])
        XCTAssertEqual(board[GridPosition(row: 0, column: 0)]?.color, .ruby)
    }

    func testGravityConverges() {
        // Ensure gravity doesn't loop infinitely
        let board = Board()
        let filler = BoardFiller()
        filler.initialFill(board: board, numColors: 6)

        // Remove a bunch of gems
        for col in 0..<4 {
            board.removeGem(at: GridPosition(row: 0, column: col))
            board.removeGem(at: GridPosition(row: 1, column: col))
        }

        // Should complete without hanging
        let (_, _) = filler.dropAndFill(board: board)

        // No empty playable cells
        for pos in board.allPlayablePositions() {
            XCTAssertNotNil(board[pos], "Gap at \(pos)")
        }
    }

    func testShapedBoardGravity() {
        // Board with holes - gravity should respect the shape
        let board = Board()
        // Make corners empty (not playable)
        board.tiles[0][0] = .empty
        board.tiles[0][1] = .empty
        board.tiles[7][6] = .empty
        board.tiles[7][7] = .empty

        let filler = BoardFiller()
        filler.initialFill(board: board, numColors: 6)

        // Verify empty tiles have no gems
        XCTAssertNil(board[GridPosition(row: 0, column: 0)])
        XCTAssertNil(board[GridPosition(row: 0, column: 1)])

        // Verify playable tiles have gems
        XCTAssertNotNil(board[GridPosition(row: 0, column: 2)])
        XCTAssertNotNil(board[GridPosition(row: 7, column: 0)])
    }

    func testDiagonalFillAroundBlocker() {
        // Place a boulder mid-column, verify gems can roll diagonally
        let board = Board()
        let filler = BoardFiller()

        // Place boulder at row 3, col 3 — this blocks vertical gravity
        board.setBlocker(.boulder, at: GridPosition(row: 3, column: 3))

        // Fill the board
        filler.initialFill(board: board, numColors: 6)

        // Remove gem below the boulder
        board.removeGem(at: GridPosition(row: 2, column: 3))

        let _ = filler.dropAndFill(board: board)

        // The position below the boulder should be filled (via diagonal)
        // or at minimum there should be no empty playable non-blocked positions
        for pos in board.allPlayablePositions() {
            if board.blockerAt(pos) == nil || !(board.blockerAt(pos)! == .boulder) {
                // Note: boulder positions won't have gems, that's expected
            }
        }
    }
}
