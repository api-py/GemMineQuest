import Foundation

class LevelGenerator {

    static func loadLevel(number: Int) -> Level? {
        let name = String(format: "level_%03d", number)
        guard let url = Bundle.main.url(forResource: name, withExtension: "json",
                                         subdirectory: "Levels"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(Level.self, from: data)
    }

    static func getLevel(number: Int) -> Level {
        if let level = loadLevel(number: number) { return level }
        return generateLevel(number: number)
    }

    static func generateLevel(number: Int) -> Level {
        var rng = SeededRandomNumberGenerator(seed: UInt64(number) &* 2654435761)

        // Gradual difficulty: 0.25 at level 50, 0.5 at level 150, 0.75 at level 300, ~0.95 at level 500
        let difficulty = min(1.0 - exp(-Double(number) / 200.0), 0.98)

        let levelType = determineLevelType(number: number, rng: &rng)
        let moves = determineMoves(difficulty: difficulty, rng: &rng)
        let numColors = determineNumColors(difficulty: difficulty, number: number, rng: &rng)
        let tileLayout = generateTileLayout(difficulty: difficulty, levelType: levelType, rng: &rng)
        let objectives = generateObjectives(levelType: levelType, difficulty: difficulty, rng: &rng)
        let targetScores = generateTargetScores(difficulty: difficulty, moves: moves)
        let blockerLayout = generateBlockers(difficulty: difficulty, tileLayout: tileLayout, rng: &rng)
        let treasureColumns = levelType == .treasureDrop ? generateTreasureColumns(tileLayout: tileLayout, rng: &rng) : nil

        return Level(
            number: number, maxMoves: moves, objectives: objectives,
            targetScores: targetScores, tileLayout: tileLayout,
            blockerLayout: blockerLayout, treasureColumns: treasureColumns,
            numColors: numColors
        )
    }

    // MARK: - Level Type

    private static func determineLevelType(number: Int, rng: inout SeededRandomNumberGenerator) -> Level.LevelType {
        let roll = Int.random(in: 0..<100, using: &rng)
        if number < 15 {
            if roll < 40 { return .scoreDig }
            return .oreExtraction
        }
        if number < 30 {
            if roll < 25 { return .scoreDig }
            if roll < 50 { return .oreExtraction }
            if roll < 75 { return .treasureDrop }
            return .collectionOrder
        }
        if roll < 15 { return .scoreDig }
        if roll < 35 { return .oreExtraction }
        if roll < 50 { return .treasureDrop }
        if roll < 65 { return .collectionOrder }
        return .mixed
    }

    // MARK: - Moves

    private static func determineMoves(difficulty: Double, rng: inout SeededRandomNumberGenerator) -> Int {
        let base = Constants.baseMoves
        let reduction = Int(Double(base - Constants.minMoves) * difficulty)
        let jitter = Int.random(in: -1...1, using: &rng)
        return max(Constants.minMoves, base - reduction + jitter)
    }

    // MARK: - Colors

    private static func determineNumColors(difficulty: Double, number: Int, rng: inout SeededRandomNumberGenerator) -> Int {
        // Start with 5 colors, gradually introduce 6th
        if number <= 20 { return 5 }
        if difficulty < 0.2 { return 5 }
        return 6
    }

    // MARK: - Tile Layout

    private static func generateTileLayout(difficulty: Double, levelType: Level.LevelType,
                                            rng: inout SeededRandomNumberGenerator) -> [[Int]] {
        let rows = 8
        let cols = 8
        var layout = Array(repeating: Array(repeating: 1, count: cols), count: rows)

        // Shape variety: always allow multiple shapes, more at higher difficulty
        let numShapeTypes = max(4, min(10, 4 + Int(difficulty * 8)))
        let shapeType = Int.random(in: 0..<numShapeTypes, using: &rng)

        if difficulty >= 0.05 {
            switch shapeType {
            case 0: // Corner cuts
                let cutSize = max(1, min(3, Int(difficulty * 4) + 1))
                for r in 0..<cutSize { for c in 0..<cutSize {
                    layout[r][c] = 0
                    layout[rows - 1 - r][cols - 1 - c] = 0
                }}
            case 1: // All 4 corners removed (cross)
                let margin = max(1, min(3, Int(difficulty * 3) + 1))
                for r in 0..<margin { for c in 0..<margin {
                    layout[r][c] = 0; layout[r][cols-1-c] = 0
                    layout[rows-1-r][c] = 0; layout[rows-1-r][cols-1-c] = 0
                }}
            case 2: // Diamond
                for r in 0..<rows { for c in 0..<cols {
                    let cR = Double(rows-1)/2.0; let cC = Double(cols-1)/2.0
                    if abs(Double(r)-cR) + abs(Double(c)-cC) > Double(max(rows,cols))/2.0 + 0.5 {
                        layout[r][c] = 0
                    }
                }}
            case 3: // Scattered holes
                let holeCount = Int(difficulty * 14) + 2
                for _ in 0..<holeCount {
                    layout[Int.random(in: 0..<rows, using: &rng)][Int.random(in: 0..<cols, using: &rng)] = 0
                }
            case 4: // Hourglass (narrow middle)
                let narrowWidth = max(3, 8 - Int(difficulty * 4))
                let margin = (cols - narrowWidth) / 2
                for r in 3...4 {
                    for c in 0..<margin { layout[r][c] = 0 }
                    for c in (cols-margin)..<cols { layout[r][c] = 0 }
                }
            case 5: // L-shape
                let cut = max(2, Int(difficulty * 3) + 1)
                for r in (rows-cut)..<rows { for c in (cols-cut)..<cols { layout[r][c] = 0 } }
            case 6: // T-shape (bottom corners removed)
                let cut = max(2, Int(difficulty * 3))
                for r in 0..<cut {
                    for c in 0..<cut { layout[r][c] = 0 }
                    for c in (cols-cut)..<cols { layout[r][c] = 0 }
                }
            case 7: // Narrow corridor
                let w = max(4, 8 - Int(difficulty * 4))
                let offset = (cols-w)/2
                for r in 0..<rows {
                    for c in 0..<offset { layout[r][c] = 0 }
                    for c in (offset+w)..<cols { layout[r][c] = 0 }
                }
            case 8: // Zigzag (alternating indents)
                for r in 0..<rows {
                    if r % 2 == 0 { layout[r][0] = 0; layout[r][1] = 0 }
                    else { layout[r][cols-1] = 0; layout[r][cols-2] = 0 }
                }
            case 9: // Ring/donut (center hollow)
                for r in 2...5 { for c in 2...5 {
                    if r >= 3 && r <= 4 && c >= 3 && c <= 4 { layout[r][c] = 0 }
                }}
            default: break
            }
        }

        // Add ore veins for appropriate level types
        if levelType == .oreExtraction || levelType == .mixed {
            let oreCount = Int.random(in: 8...20, using: &rng)
            var placed = 0
            for _ in 0..<200 {
                guard placed < oreCount else { break }
                let r = Int.random(in: 0..<rows, using: &rng)
                let c = Int.random(in: 0..<cols, using: &rng)
                if layout[r][c] == 1 {
                    layout[r][c] = difficulty > 0.3 && Bool.random(using: &rng) ? 3 : 2
                    placed += 1
                }
            }
        }

        // For higher difficulty levels, add 2x2 gap blocks to increase strategic difficulty
        if difficulty >= 0.22 {
            let playableCount = layout.flatMap { $0 }.filter { $0 != 0 }.count
            if playableCount > 58 {
                let gapCount = difficulty >= 0.35 ? 2 : 1
                var gapsPlaced = 0
                for _ in 0..<50 {
                    guard gapsPlaced < gapCount else { break }
                    let gr = Int.random(in: 1..<(rows - 1), using: &rng)
                    let gc = Int.random(in: 1..<(cols - 1), using: &rng)
                    let positions = [(gr, gc), (gr, gc + 1), (gr + 1, gc), (gr + 1, gc + 1)]
                    if positions.allSatisfy({ r, c in
                        r < rows && c < cols && layout[r][c] == 1
                    }) {
                        for (r, c) in positions { layout[r][c] = 0 }
                        gapsPlaced += 1
                    }
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
            let target = Int(Double(Int.random(in: 4000...10000, using: &rng)) * (1.0 + difficulty))
            return [.reachScore(target: target)]
        case .oreExtraction:
            return [.clearAllOre]
        case .treasureDrop:
            return [.dropTreasures(count: Int.random(in: 2...5, using: &rng))]
        case .collectionOrder:
            let color = GemColor(rawValue: Int.random(in: 0..<6, using: &rng)) ?? .ruby
            let count = Int.random(in: 18...45, using: &rng)
            return [.collectGems(color: color, count: count)]
        case .mixed:
            let roll = Int.random(in: 0..<3, using: &rng)
            if roll == 0 {
                return [.clearAllOre, .reachScore(target: Int.random(in: 3000...6000, using: &rng))]
            } else if roll == 1 {
                return [.clearAllOre, .dropTreasures(count: Int.random(in: 1...3, using: &rng))]
            } else {
                let color = GemColor(rawValue: Int.random(in: 0..<6, using: &rng)) ?? .ruby
                return [.collectGems(color: color, count: Int.random(in: 12...30, using: &rng)),
                        .reachScore(target: Int.random(in: 2500...5000, using: &rng))]
            }
        }
    }

    // MARK: - Target Scores

    private static func generateTargetScores(difficulty: Double, moves: Int) -> [Int] {
        let baseScore = moves * 250
        let scale = 1.0 + difficulty * 2.5
        return [
            Int(Double(baseScore) * scale * 0.5),
            Int(Double(baseScore) * scale * 1.0),
            Int(Double(baseScore) * scale * 1.6)
        ]
    }

    // MARK: - Blockers

    private static func generateBlockers(difficulty: Double, tileLayout: [[Int]],
                                          rng: inout SeededRandomNumberGenerator) -> [[Level.BlockerData?]]? {
        guard difficulty > 0.05 else { return nil }

        let rows = tileLayout.count; let cols = tileLayout.first?.count ?? 8
        var layout: [[Level.BlockerData?]] = Array(repeating: Array(repeating: nil, count: cols), count: rows)

        // Gradual blocker increase: 1-2 at easy, up to 15 at hardest
        let blockerCount = max(1, Int(difficulty * 16))
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
            } else if roll < 65 && difficulty > 0.12 {
                layout[r][c] = Level.BlockerData(type: "cage", value: nil)
            } else if roll < 75 && difficulty > 0.18 {
                layout[r][c] = Level.BlockerData(type: "lava", value: nil)
            } else if roll < 85 && difficulty > 0.30 {
                layout[r][c] = Level.BlockerData(type: "tnt", value: max(5, 15 - Int(difficulty * 10)))
            } else if difficulty > 0.15 {
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
        var valid: [Int] = []
        for c in 0..<cols { if tileLayout[0][c] != 0 { valid.append(c) } }
        let count = min(valid.count, Int.random(in: 1...3, using: &rng))
        return Array(valid.shuffled(using: &rng).prefix(count))
    }

    @MainActor static func createGameState(levelNumber: Int) -> GameState {
        let level = getLevel(number: levelNumber)
        let board = level.buildBoard()
        return GameState(level: level, board: board)
    }
}
