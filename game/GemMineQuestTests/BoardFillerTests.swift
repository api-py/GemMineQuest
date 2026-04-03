import XCTest
@testable import GemMineQuest

final class BoardFillerTests: XCTestCase {

    func testInitialFillNoMatches() {
        let board = Board(numRows: 8, numColumns: 8)
        let filler = BoardFiller()
        let detector = MatchDetector()

        filler.initialFill(board: board, numColors: 6)

        // Verify all tiles have gems
        for row in 0..<8 {
            for col in 0..<8 {
                XCTAssertNotNil(board[row, col], "Gem missing at (\(row), \(col))")
            }
        }

        // Verify no pre-existing matches
        let matches = detector.detectMatches(on: board)
        XCTAssertTrue(matches.isEmpty, "Board has pre-existing matches after initial fill")
    }

    func testSeededFillIsDeterministic() {
        let board1 = Board(numRows: 8, numColumns: 8)
        let board2 = Board(numRows: 8, numColumns: 8)
        let filler = BoardFiller()

        filler.initialFill(board: board1, numColors: 6, seed: 12345)
        filler.initialFill(board: board2, numColors: 6, seed: 12345)

        for row in 0..<8 {
            for col in 0..<8 {
                XCTAssertEqual(board1[row, col]?.color, board2[row, col]?.color,
                               "Mismatch at (\(row), \(col))")
            }
        }
    }

    func testDropAndFillFillsGaps() {
        let board = Board(numRows: 8, numColumns: 8)
        let filler = BoardFiller()
        filler.initialFill(board: board, numColors: 6)

        // Remove some gems
        board.removeGem(at: GridPosition(row: 0, column: 0))
        board.removeGem(at: GridPosition(row: 1, column: 0))
        board.removeGem(at: GridPosition(row: 0, column: 3))

        let (falls, newGems) = filler.dropAndFill(board: board)

        // After fill, all positions should have gems
        for row in 0..<8 {
            for col in 0..<8 {
                XCTAssertNotNil(board[row, col], "Missing gem at (\(row), \(col))")
            }
        }

        XCTAssertFalse(falls.isEmpty || newGems.isEmpty,
                       "Should have fall and new gem events")
    }
}
