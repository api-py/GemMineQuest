import XCTest
@testable import GemMineQuest

final class SpecialGemResolverTests: XCTestCase {

    let resolver = SpecialGemResolver()

    func testHorizontalLaserClearsRow() {
        let board = Board(numRows: 8, numColumns: 8)
        let filler = BoardFiller()
        filler.initialFill(board: board, numColors: 6)

        let pos = GridPosition(row: 3, column: 4)
        let affected = resolver.resolve(special: .laserHorizontal, at: pos, on: board)

        // Should affect all 8 columns in row 3
        XCTAssertEqual(affected.count, 8)
        for col in 0..<8 {
            XCTAssertTrue(affected.contains(GridPosition(row: 3, column: col)))
        }
    }

    func testVerticalLaserClearsColumn() {
        let board = Board(numRows: 8, numColumns: 8)
        let filler = BoardFiller()
        filler.initialFill(board: board, numColors: 6)

        let pos = GridPosition(row: 3, column: 4)
        let affected = resolver.resolve(special: .laserVertical, at: pos, on: board)

        // Should affect all 8 rows in column 4
        XCTAssertEqual(affected.count, 8)
        for row in 0..<8 {
            XCTAssertTrue(affected.contains(GridPosition(row: row, column: 4)))
        }
    }

    func testVolatileClears3x3() {
        let board = Board(numRows: 8, numColumns: 8)
        let filler = BoardFiller()
        filler.initialFill(board: board, numColors: 6)

        let pos = GridPosition(row: 3, column: 3)
        let affected = resolver.resolve(special: .volatile, at: pos, on: board)

        // 3x3 area = 9 tiles
        XCTAssertEqual(affected.count, 9)
    }

    func testCrystalBallClearsColor() {
        let board = Board(numRows: 8, numColumns: 8)

        // Place 10 rubies and fill rest with sapphire
        var rubyCount = 0
        for row in 0..<8 {
            for col in 0..<8 {
                let pos = GridPosition(row: row, column: col)
                if rubyCount < 10 && (row + col) % 3 == 0 {
                    board.setGem(Gem(color: .ruby, row: row, column: col), at: pos)
                    rubyCount += 1
                } else {
                    board.setGem(Gem(color: .sapphire, row: row, column: col), at: pos)
                }
            }
        }

        let affected = resolver.resolveCrystalBall(targetColor: .ruby, on: board)
        XCTAssertEqual(affected.count, rubyCount)
    }

    func testDoubleCrystalBallClearsAll() {
        let board = Board(numRows: 8, numColumns: 8)
        let filler = BoardFiller()
        filler.initialFill(board: board, numColors: 6)

        let posA = GridPosition(row: 3, column: 3)
        let posB = GridPosition(row: 3, column: 4)

        let affected = resolver.resolveCombo(
            specialA: .crystalBall, posA: posA,
            specialB: .crystalBall, posB: posB,
            on: board
        )

        // Should clear entire board (all positions with gems)
        let allGems = board.allGems().count
        XCTAssertEqual(affected.count, allGems)
    }

    func testLaserLaserComboMakesCross() {
        let board = Board(numRows: 8, numColumns: 8)
        let filler = BoardFiller()
        filler.initialFill(board: board, numColors: 6)

        let pos = GridPosition(row: 3, column: 4)
        let affected = resolver.resolveCombo(
            specialA: .laserHorizontal, posA: pos,
            specialB: .laserVertical, posB: pos,
            on: board
        )

        // Should cover entire row 3 + entire column 4 = 8 + 8 - 1 = 15
        XCTAssertEqual(affected.count, 15)
    }
}
