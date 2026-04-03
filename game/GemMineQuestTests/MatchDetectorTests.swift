import XCTest
@testable import GemMineQuest

final class MatchDetectorTests: XCTestCase {

    let detector = MatchDetector()

    private func makeBoard() -> Board {
        Board(numRows: 8, numColumns: 8)
    }

    private func placeGem(_ board: Board, color: GemColor, row: Int, col: Int) {
        let gem = Gem(color: color, row: row, column: col)
        board.setGem(gem, at: GridPosition(row: row, column: col))
    }

    func testHorizontalMatch3() {
        let board = makeBoard()
        placeGem(board, color: .ruby, row: 0, col: 0)
        placeGem(board, color: .ruby, row: 0, col: 1)
        placeGem(board, color: .ruby, row: 0, col: 2)
        // Fill rest with different colors to avoid false matches
        placeGem(board, color: .sapphire, row: 0, col: 3)

        let matches = detector.detectMatches(on: board)
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches[0].positions.count, 3)
        XCTAssertEqual(matches[0].pattern, .three)
    }

    func testHorizontalMatch4CreatesLaser() {
        let board = makeBoard()
        for col in 0..<4 {
            placeGem(board, color: .emerald, row: 2, col: col)
        }
        placeGem(board, color: .sapphire, row: 2, col: 4)

        let matches = detector.detectMatches(on: board)
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches[0].positions.count, 4)
        XCTAssertEqual(matches[0].pattern, .four)
        XCTAssertNotNil(matches[0].specialType)
        // Horizontal match creates vertical laser
        XCTAssertEqual(matches[0].specialType, .laserVertical)
    }

    func testVerticalMatch5CreatesCrystalBall() {
        let board = makeBoard()
        for row in 0..<5 {
            placeGem(board, color: .amethyst, row: row, col: 3)
        }
        placeGem(board, color: .ruby, row: 5, col: 3)

        let matches = detector.detectMatches(on: board)
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches[0].positions.count, 5)
        XCTAssertEqual(matches[0].pattern, .five)
        XCTAssertEqual(matches[0].specialType, .crystalBall)
    }

    func testSquareMatchCreatesDrone() {
        let board = makeBoard()
        placeGem(board, color: .topaz, row: 0, col: 0)
        placeGem(board, color: .topaz, row: 0, col: 1)
        placeGem(board, color: .topaz, row: 1, col: 0)
        placeGem(board, color: .topaz, row: 1, col: 1)
        // Different colors around
        placeGem(board, color: .ruby, row: 0, col: 2)
        placeGem(board, color: .sapphire, row: 1, col: 2)

        let matches = detector.detectMatches(on: board)
        let squareMatches = matches.filter { $0.pattern == .square }
        XCTAssertEqual(squareMatches.count, 1)
        XCTAssertEqual(squareMatches[0].specialType, .miningDrone)
    }

    func testNoMatchReturnsEmpty() {
        let board = makeBoard()
        placeGem(board, color: .ruby, row: 0, col: 0)
        placeGem(board, color: .sapphire, row: 0, col: 1)
        placeGem(board, color: .emerald, row: 0, col: 2)

        let matches = detector.detectMatches(on: board)
        XCTAssertTrue(matches.isEmpty)
    }

    func testWouldMatch() {
        let board = makeBoard()
        placeGem(board, color: .ruby, row: 0, col: 0)
        placeGem(board, color: .ruby, row: 0, col: 1)
        placeGem(board, color: .sapphire, row: 0, col: 2)
        placeGem(board, color: .ruby, row: 0, col: 3)

        let from = GridPosition(row: 0, column: 2)
        let to = GridPosition(row: 0, column: 3)

        XCTAssertTrue(detector.wouldMatch(board: board, swapping: from, with: to))
    }
}
