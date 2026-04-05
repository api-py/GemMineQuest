import XCTest
@testable import GemMineQuest

final class LevelGeneratorTests: XCTestCase {

    func testProceduralLevelGeneration() {
        let level = LevelGenerator.generateLevel(number: 50)

        XCTAssertEqual(level.number, 50)
        XCTAssertGreaterThan(level.maxMoves, 0)
        XCTAssertFalse(level.objectives.isEmpty)
        XCTAssertEqual(level.targetScores.count, 3)
        XCTAssertEqual(level.tileLayout.count, 8)
        XCTAssertEqual(level.tileLayout[0].count, 8)

        // Target scores should be ascending
        XCTAssertLessThanOrEqual(level.targetScores[0], level.targetScores[1])
        XCTAssertLessThanOrEqual(level.targetScores[1], level.targetScores[2])
    }

    func testProceduralLevelIsDeterministic() {
        let level1 = LevelGenerator.generateLevel(number: 42)
        let level2 = LevelGenerator.generateLevel(number: 42)

        XCTAssertEqual(level1.maxMoves, level2.maxMoves)
        XCTAssertEqual(level1.tileLayout, level2.tileLayout)
        XCTAssertEqual(level1.targetScores, level2.targetScores)
    }

    func testDifficultyIncreases() {
        let easyLevel = LevelGenerator.generateLevel(number: 15)
        let hardLevel = LevelGenerator.generateLevel(number: 150)

        // Hard level should generally have fewer moves
        XCTAssertGreaterThanOrEqual(easyLevel.maxMoves, hardLevel.maxMoves)
    }

    @MainActor func testCreateGameState() {
        let state = LevelGenerator.createGameState(levelNumber: 1)

        XCTAssertEqual(state.level.number, 1)
        XCTAssertGreaterThan(state.movesRemaining, 0)
        XCTAssertEqual(state.score, 0)
    }

    func testHighLevelGeneration() {
        // Verify we can generate very high level numbers without crashing
        for levelNum in [100, 500, 1000, 9999] {
            let level = LevelGenerator.generateLevel(number: levelNum)
            XCTAssertEqual(level.number, levelNum)
            XCTAssertGreaterThan(level.maxMoves, 0)
            XCTAssertFalse(level.objectives.isEmpty)
        }
    }
}
