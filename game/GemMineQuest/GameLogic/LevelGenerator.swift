import Foundation

class LevelGenerator {

    /// Load a handcrafted level from JSON bundle
    static func loadLevel(number: Int) -> Level? {
        let name = String(format: "level_%03d", number)
        guard let url = Bundle.main.url(forResource: name, withExtension: "json",
                                         subdirectory: "Levels"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? JSONDecoder().decode(Level.self, from: data)
    }

    /// Get a level - handcrafted if available, procedurally generated otherwise
    static func getLevel(number: Int) -> Level {
        // Try loading handcrafted level first
        if let level = loadLevel(number: number) {
            return level
        }
        // Fall back to procedural generation
        return generateLevel(number: number)
    }

    /// Procedurally generate a level based on its number (deterministic)
    static func generateLevel(number: Int) -> Level {
        var rng = SeededRandomNumberGenerator(seed: UInt64(number) &* 2654435761)

        let difficulty = min(Double(number) / 200.0, 1.0) // 0.0 to 1.0

        let levelType = determineLevelType(number: number, rng: &rng)
        let moves = determineMoves(difficulty: difficulty, rng: &rng)
        let numColors = determineNumColors(difficulty: difficulty, rng: &rng)
        let tileLayout = generateTileLayout(difficulty: difficulty, levelType: levelType, rng: &rng)
        let objectives = generateObjectives(levelType: levelType, difficulty: difficulty, rng: &rng)
        let targetScores = generateTargetScores(difficulty: difficulty, moves: moves)
        let blockerLayout = generateBlockers(difficulty: difficulty, tileLayout: tileLayout, rng: &rng)
        let treasureColumns = levelType == .treasureDrop ? generateTreasureColumns(tileLayout: tileLayout, rng: &rng) : nil

        return Level(
            number: number,
            maxMoves: moves,
            objectives: objectives,
            targetScores: targetScores,
            tileLayout: tileLayout,
            blockerLayout: blockerLayout,
            treasureColumns: treasureColumns,
            numColors: numColors
        )
    }

    // MARK: - Level Type

    private static func determineLevelType(number: Int, rng: inout SeededRandomNumberGenerator) -> Level.LevelType {
        // Cycle through types with weighted distribution
        let roll = Int.random(in: 0..<100, using: &rng)

        if number < 15 {
            // Early game: mostly score and ore
            if roll < 50 { return .scoreDig }
            return .oreExtraction
        }

        if number < 30 {
            if roll < 30 { return .scoreDig }
            if roll < 55 { return .oreExtraction }
            if roll < 80 { return .treasureDrop }
            return .collectionOrder
        }

        // Later game: all types including mixed
        if roll < 20 { return .scoreDig }
        if roll < 40 { return .oreExtraction }
        if roll < 55 { return .treasureDrop }
        if roll < 70 { return .collectionOrder }
        return .mixed
    }

    // MARK: - Moves

    private static func determineMoves(difficulty: Double, rng: inout SeededRandomNumberGenerator) -> Int {
        let base = Constants.baseMoves
        let reduction = Int(Double(base - Constants.minMoves) * difficulty)
        let jitter = Int.random(in: -2...2, using: &rng)
        return max(Constants.minMoves, base - reduction + jitter)
    }

    // MARK: - Colors

    private static func determineNumColors(difficulty: Double, rng: inout SeededRandomNumberGenerator) -> Int {
        if difficulty < 0.1 { return 4 }  // Very early: easier with fewer colors
        if difficulty < 0.3 { return 5 }
        return 6
    }

    // MARK: - Tile Layout

    private static func generateTileLayout(difficulty: Double, levelType: Level.LevelType,
                                            rng: inout SeededRandomNumberGenerator) -> [[Int]] {
        let rows = 8
        let cols = 8
        var layout = Array(repeating: Array(repeating: 1, count: cols), count: rows)

        // Add shape variation based on difficulty
        let shapeComplexity = min(difficulty * 2.0, 1.0)
        let holesToAdd = Int(shapeComplexity * 8)

        if holesToAdd > 0 {
            // Create interesting board shapes
            let shapeType = Int.random(in: 0..<5, using: &rng)

            switch shapeType {
            case 0:
                // Corner cuts
                let cutSize = max(1, Int.random(in: 1...3, using: &rng))
                for r in 0..<cutSize {
                    for c in 0..<cutSize {
                        layout[r][c] = 0
                        layout[rows - 1 - r][cols - 1 - c] = 0
                    }
                }
            case 1:
                // Cross shape (remove corners)
                let margin = max(1, Int.random(in: 1...2, using: &rng))
                for r in 0..<margin {
                    for c in 0..<margin {
                        layout[r][c] = 0
                        layout[r][cols - 1 - c] = 0
                        layout[rows - 1 - r][c] = 0
                        layout[rows - 1 - r][cols - 1 - c] = 0
                    }
                }
            case 2:
                // Diamond shape
                for r in 0..<rows {
                    for c in 0..<cols {
                        let centerR = Double(rows - 1) / 2.0
                        let centerC = Double(cols - 1) / 2.0
                        let dist = abs(Double(r) - centerR) + abs(Double(c) - centerC)
                        if dist > Double(max(rows, cols)) / 2.0 + 0.5 {
                            layout[r][c] = 0
                        }
                    }
                }
            case 3:
                // Random holes
                for _ in 0..<holesToAdd {
                    let r = Int.random(in: 0..<rows, using: &rng)
                    let c = Int.random(in: 0..<cols, using: &rng)
                    layout[r][c] = 0
                }
            default:
                break // Full board
            }
        }

        // Add ore veins for ore extraction levels
        if levelType == .oreExtraction || levelType == .mixed {
            let oreCount = Int.random(in: 8...20, using: &rng)
            var placed = 0
            for _ in 0..<100 {
                guard placed < oreCount else { break }
                let r = Int.random(in: 0..<rows, using: &rng)
                let c = Int.random(in: 0..<cols, using: &rng)
                if layout[r][c] == 1 {
                    // Single or double ore based on difficulty
                    layout[r][c] = difficulty > 0.3 && Bool.random(using: &rng) ? 3 : 2
                    placed += 1
                }
            }
        }

        return layout
    }

    // MARK: - Objectives

    private static func generateObjectives(levelType: Level.LevelType, difficulty: Double,
                                            rng: inout SeededRandomNumberGenerator) -> [LevelObjective] {
        switch levelType {
        case .scoreDig:
            let target = Int(Double(Int.random(in: 3000...8000, using: &rng)) * (1.0 + difficulty))
            return [.reachScore(target: target)]

        case .oreExtraction:
            return [.clearAllOre]

        case .treasureDrop:
            let count = Int.random(in: 2...5, using: &rng)
            return [.dropTreasures(count: count)]

        case .collectionOrder:
            let colorIndex = Int.random(in: 0..<6, using: &rng)
            let color = GemColor(rawValue: colorIndex) ?? .ruby
            let count = Int.random(in: 15...40, using: &rng)
            return [.collectGems(color: color, count: count)]

        case .mixed:
            var objectives: [LevelObjective] = []
            let roll = Int.random(in: 0..<3, using: &rng)
            if roll == 0 {
                objectives.append(.clearAllOre)
                let target = Int.random(in: 2000...5000, using: &rng)
                objectives.append(.reachScore(target: target))
            } else if roll == 1 {
                objectives.append(.clearAllOre)
                objectives.append(.dropTreasures(count: Int.random(in: 1...3, using: &rng)))
            } else {
                let colorIndex = Int.random(in: 0..<6, using: &rng)
                let color = GemColor(rawValue: colorIndex) ?? .ruby
                objectives.append(.collectGems(color: color, count: Int.random(in: 10...25, using: &rng)))
                objectives.append(.reachScore(target: Int.random(in: 2000...4000, using: &rng)))
            }
            return objectives
        }
    }

    // MARK: - Target Scores

    private static func generateTargetScores(difficulty: Double, moves: Int) -> [Int] {
        let baseScore = moves * 200
        let scale = 1.0 + difficulty * 2.0
        let oneStar = Int(Double(baseScore) * scale * 0.5)
        let twoStar = Int(Double(baseScore) * scale * 1.0)
        let threeStar = Int(Double(baseScore) * scale * 1.5)
        return [oneStar, twoStar, threeStar]
    }

    // MARK: - Blockers

    private static func generateBlockers(difficulty: Double, tileLayout: [[Int]],
                                          rng: inout SeededRandomNumberGenerator) -> [[Level.BlockerData?]]? {
        guard difficulty > 0.15 else { return nil }

        let rows = tileLayout.count
        let cols = tileLayout.first?.count ?? 8
        var layout: [[Level.BlockerData?]] = Array(repeating: Array(repeating: nil, count: cols), count: rows)

        let blockerCount = Int(difficulty * 10)
        guard blockerCount > 0 else { return nil }

        var placed = 0
        for _ in 0..<200 {
            guard placed < blockerCount else { break }
            let r = Int.random(in: 0..<rows, using: &rng)
            let c = Int.random(in: 0..<cols, using: &rng)
            guard tileLayout[r][c] == 1, layout[r][c] == nil else { continue }

            let roll = Int.random(in: 0..<100, using: &rng)
            if roll < 30 {
                let layers = min(Int(difficulty * 4) + 1, 3)
                layout[r][c] = Level.BlockerData(type: "granite", value: layers)
            } else if roll < 50 {
                layout[r][c] = Level.BlockerData(type: "boulder", value: nil)
            } else if roll < 65 && difficulty > 0.3 {
                layout[r][c] = Level.BlockerData(type: "cage", value: nil)
            } else if roll < 75 && difficulty > 0.4 {
                layout[r][c] = Level.BlockerData(type: "lava", value: nil)
            } else if roll < 85 && difficulty > 0.5 {
                let countdown = max(5, 15 - Int(difficulty * 10))
                layout[r][c] = Level.BlockerData(type: "tnt", value: countdown)
            } else if difficulty > 0.35 {
                layout[r][c] = Level.BlockerData(type: "amber", value: nil)
            }

            if layout[r][c] != nil { placed += 1 }
        }

        return placed > 0 ? layout : nil
    }

    // MARK: - Treasure Columns

    private static func generateTreasureColumns(tileLayout: [[Int]],
                                                 rng: inout SeededRandomNumberGenerator) -> [Int] {
        let cols = tileLayout.first?.count ?? 8
        var validCols: [Int] = []
        for c in 0..<cols {
            if tileLayout[0][c] != 0 { // Bottom row must be playable
                validCols.append(c)
            }
        }
        let count = min(validCols.count, Int.random(in: 1...3, using: &rng))
        return Array(validCols.shuffled(using: &rng).prefix(count))
    }

    /// Create a GameState for a given level number
    static func createGameState(levelNumber: Int) -> GameState {
        let level = getLevel(number: levelNumber)
        let board = level.buildBoard()
        let state = GameState(level: level, board: board)
        return state
    }
}
