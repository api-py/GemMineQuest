import XCTest
@testable import GemMineQuest

final class MatchDetectorTests: XCTestCase {

    let detector = MatchDetector()

    private func makeBoard() -> Board { Board() }

    private func place(_ board: Board, _ color: GemColor, _ row: Int, _ col: Int) {
        board.setGem(Gem(color: color, row: row, column: col), at: GridPosition(row: row, column: col))
    }

    // MARK: - Basic 3-in-a-row

    func testHorizontalMatch3() {
        let board = makeBoard()
        place(board, .ruby, 0, 0); place(board, .ruby, 0, 1); place(board, .ruby, 0, 2)
        place(board, .sapphire, 0, 3)
        let matches = detector.detectMatches(on: board)
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches[0].positions.count, 3)
        XCTAssertEqual(matches[0].pattern, .three)
        XCTAssertNil(matches[0].specialType, "3-match should NOT create a special")
    }

    func testVerticalMatch3() {
        let board = makeBoard()
        place(board, .emerald, 0, 0); place(board, .emerald, 1, 0); place(board, .emerald, 2, 0)
        place(board, .ruby, 3, 0)
        let matches = detector.detectMatches(on: board)
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches[0].positions.count, 3)
    }

    func testNoMatchReturnsEmpty() {
        let board = makeBoard()
        place(board, .ruby, 0, 0); place(board, .sapphire, 0, 1); place(board, .emerald, 0, 2)
        XCTAssertTrue(detector.detectMatches(on: board).isEmpty)
    }

    func testTwoSeparateMatches() {
        let board = makeBoard()
        // Row 0: 3 rubies
        place(board, .ruby, 0, 0); place(board, .ruby, 0, 1); place(board, .ruby, 0, 2)
        place(board, .sapphire, 0, 3)
        // Row 2: 3 emeralds
        place(board, .emerald, 2, 0); place(board, .emerald, 2, 1); place(board, .emerald, 2, 2)
        let matches = detector.detectMatches(on: board)
        XCTAssertEqual(matches.count, 2)
    }

    // MARK: - 4-in-a-row → Laser Gem

    func testHorizontalMatch4CreatesLaser() {
        let board = makeBoard()
        place(board, .emerald, 2, 0); place(board, .emerald, 2, 1)
        place(board, .emerald, 2, 2); place(board, .emerald, 2, 3)
        place(board, .sapphire, 2, 4)
        let matches = detector.detectMatches(on: board)
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches[0].positions.count, 4)
        XCTAssertEqual(matches[0].pattern, .four)
        // Horizontal 4-match creates VERTICAL laser (perpendicular)
        XCTAssertEqual(matches[0].specialType, .laserVertical)
    }

    func testVerticalMatch4CreatesLaser() {
        let board = makeBoard()
        place(board, .gold, 0, 3); place(board, .gold, 1, 3)
        place(board, .gold, 2, 3); place(board, .gold, 3, 3)
        place(board, .ruby, 4, 3)
        let matches = detector.detectMatches(on: board)
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches[0].pattern, .four)
        // Vertical 4-match creates HORIZONTAL laser (perpendicular)
        XCTAssertEqual(matches[0].specialType, .laserHorizontal)
    }

    // MARK: - 5-in-a-row → Crystal Ball

    func testVerticalMatch5CreatesCrystalBall() {
        let board = makeBoard()
        for row in 0..<5 { place(board, .amethyst, row, 3) }
        place(board, .ruby, 5, 3)
        let matches = detector.detectMatches(on: board)
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches[0].pattern, .five)
        XCTAssertEqual(matches[0].specialType, .crystalBall)
    }

    func testHorizontalMatch5CreatesCrystalBall() {
        let board = makeBoard()
        for col in 0..<5 { place(board, .silver, 1, col) }
        place(board, .ruby, 1, 5)
        let matches = detector.detectMatches(on: board)
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches[0].specialType, .crystalBall)
    }

    // MARK: - 2x2 Square → Mining Drone

    func testSquareMatchCreatesDrone() {
        let board = makeBoard()
        place(board, .gold, 0, 0); place(board, .gold, 0, 1)
        place(board, .gold, 1, 0); place(board, .gold, 1, 1)
        place(board, .ruby, 0, 2); place(board, .sapphire, 1, 2)
        let matches = detector.detectMatches(on: board)
        let squares = matches.filter { $0.pattern == .square }
        XCTAssertEqual(squares.count, 1)
        XCTAssertEqual(squares[0].specialType, .miningDrone)
    }

    // MARK: - L-Shape → Volatile Gem

    func testLShapeCreatesVolatile() {
        let board = makeBoard()
        // Horizontal: row 0, cols 0-2 (3 rubies)
        place(board, .ruby, 0, 0); place(board, .ruby, 0, 1); place(board, .ruby, 0, 2)
        // Vertical: rows 0-2, col 0 (3 rubies, sharing (0,0))
        place(board, .ruby, 1, 0); place(board, .ruby, 2, 0)
        // Fill other positions with different colors
        place(board, .sapphire, 0, 3); place(board, .sapphire, 3, 0)
        let matches = detector.detectMatches(on: board)
        let lShapes = matches.filter { $0.pattern == .lShape }
        XCTAssertFalse(lShapes.isEmpty, "L-shape should be detected")
        XCTAssertEqual(lShapes[0].specialType, .volatile)
    }

    func testTShapeCreatesVolatile() {
        let board = makeBoard()
        // Horizontal: row 2, cols 0-2 (3 emeralds)
        place(board, .emerald, 2, 0); place(board, .emerald, 2, 1); place(board, .emerald, 2, 2)
        // Vertical: rows 1-3, col 1 (3 emeralds, sharing (2,1))
        place(board, .emerald, 1, 1); place(board, .emerald, 3, 1)
        place(board, .ruby, 0, 1); place(board, .ruby, 4, 1)
        let matches = detector.detectMatches(on: board)
        let volatiles = matches.filter { $0.specialType == .volatile }
        XCTAssertFalse(volatiles.isEmpty, "T-shape should create volatile gem")
    }

    // MARK: - Adjacent matches don't interfere

    func testAdjacentDifferentColorsDontMatch() {
        let board = makeBoard()
        place(board, .ruby, 0, 0); place(board, .ruby, 0, 1)
        place(board, .sapphire, 0, 2); place(board, .sapphire, 0, 3); place(board, .sapphire, 0, 4)
        let matches = detector.detectMatches(on: board)
        XCTAssertEqual(matches.count, 1) // Only the sapphire match
        XCTAssertEqual(matches[0].color, .sapphire)
    }

    // MARK: - Would Match (swap validation)

    func testWouldMatch() {
        let board = makeBoard()
        place(board, .ruby, 0, 0); place(board, .ruby, 0, 1)
        place(board, .sapphire, 0, 2); place(board, .ruby, 0, 3)
        let from = GridPosition(row: 0, column: 2)
        let to = GridPosition(row: 0, column: 3)
        XCTAssertTrue(detector.wouldMatch(board: board, swapping: from, with: to))
    }

    func testWouldNotMatch() {
        let board = makeBoard()
        place(board, .ruby, 0, 0); place(board, .sapphire, 0, 1)
        place(board, .emerald, 0, 2); place(board, .gold, 0, 3)
        let from = GridPosition(row: 0, column: 0)
        let to = GridPosition(row: 0, column: 1)
        XCTAssertFalse(detector.wouldMatch(board: board, swapping: from, with: to))
    }
}
