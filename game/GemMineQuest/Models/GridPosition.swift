import Foundation

struct GridPosition: Hashable, Codable, CustomStringConvertible {
    let row: Int
    let column: Int

    var description: String {
        "(\(row), \(column))"
    }

    var neighbors: [GridPosition] {
        [
            GridPosition(row: row - 1, column: column),
            GridPosition(row: row + 1, column: column),
            GridPosition(row: row, column: column - 1),
            GridPosition(row: row, column: column + 1)
        ]
    }

    var allEightNeighbors: [GridPosition] {
        var result: [GridPosition] = []
        for dr in -1...1 {
            for dc in -1...1 {
                if dr == 0 && dc == 0 { continue }
                result.append(GridPosition(row: row + dr, column: column + dc))
            }
        }
        return result
    }

    static func isAdjacent(_ a: GridPosition, _ b: GridPosition) -> Bool {
        let dr = abs(a.row - b.row)
        let dc = abs(a.column - b.column)
        return (dr == 1 && dc == 0) || (dr == 0 && dc == 1)
    }

    func distance(to other: GridPosition) -> Int {
        abs(row - other.row) + abs(column - other.column)
    }
}
