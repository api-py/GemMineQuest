import Foundation

struct Level: Codable {
    let number: Int
    let maxMoves: Int
    let objectives: [LevelObjective]
    let targetScores: [Int]  // [1-star, 2-star, 3-star]
    let tileLayout: [[Int]]  // 8x8 grid of TileType raw values
    let blockerLayout: [[BlockerData?]]?
    let treasureColumns: [Int]?  // Columns with mine cart exits for treasure drop levels
    let numColors: Int?  // Number of gem colors to use (default 6)

    struct BlockerData: Codable {
        let type: String  // "granite", "boulder", "cage", "lava", "tnt", "amber"
        let value: Int?   // Layers for granite, countdown for tnt
    }

    var levelType: LevelType {
        if objectives.contains(where: { if case .clearAllOre = $0 { return true }; return false }) {
            if objectives.count > 1 { return .mixed }
            return .oreExtraction
        }
        if objectives.contains(where: { if case .dropTreasures = $0 { return true }; return false }) {
            if objectives.count > 1 { return .mixed }
            return .treasureDrop
        }
        if objectives.contains(where: {
            if case .collectGems = $0 { return true }
            if case .collectSpecials = $0 { return true }
            return false
        }) {
            if objectives.count > 1 { return .mixed }
            return .collectionOrder
        }
        return .scoreDig
    }

    enum LevelType: String {
        case scoreDig
        case oreExtraction
        case treasureDrop
        case collectionOrder
        case mixed
    }

    func buildBoard() -> Board {
        let numRows = tileLayout.count
        let numCols = tileLayout.first?.count ?? Constants.defaultGridColumns
        guard numRows > 0 && numCols > 0 else {
            return Board()
        }
        let board = Board(numRows: numRows, numColumns: numCols)

        for row in 0..<numRows {
            let rowData = tileLayout[row]
            for col in 0..<numCols {
                guard col < rowData.count else { continue }
                let tileValue = rowData[col]
                board.tiles[row][col] = TileType(rawValue: tileValue) ?? .normal

                if let blockerLayout = blockerLayout,
                   row < blockerLayout.count, col < blockerLayout[row].count,
                   let data = blockerLayout[row][col] {
                    board.blockers[row][col] = data.toBlockerType()
                }
            }
        }

        // Set mine cart exits
        if let columns = treasureColumns {
            for col in columns {
                if col >= 0 && col < numCols {
                    board.tiles[0][col] = .mineCart
                }
            }
        }

        return board
    }

    var effectiveNumColors: Int {
        min(max(numColors ?? 6, 3), 6)
    }
}

extension Level.BlockerData {
    func toBlockerType() -> BlockerType? {
        switch type {
        case "granite": return .granite(layers: value ?? 1)
        case "boulder": return .boulder
        case "cage": return .cage
        case "lava": return .lava
        case "tnt": return .tnt(countdown: value ?? 10)
        case "amber": return .amber
        default: return nil
        }
    }
}
