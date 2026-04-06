import Foundation

class Board {
    let numRows: Int
    let numColumns: Int
    private var grid: [[Gem?]]
    var tiles: [[TileType]]
    var blockers: [[BlockerType?]]

    init(numRows: Int = Constants.defaultGridRows, numColumns: Int = Constants.defaultGridColumns) {
        self.numRows = numRows
        self.numColumns = numColumns
        self.grid = Array(repeating: Array(repeating: nil, count: numColumns), count: numRows)
        self.tiles = Array(repeating: Array(repeating: .normal, count: numColumns), count: numRows)
        self.blockers = Array(repeating: Array(repeating: nil, count: numColumns), count: numRows)
    }

    // MARK: - Subscript Access

    subscript(row: Int, col: Int) -> Gem? {
        get {
            guard isValidPosition(row: row, col: col) else { return nil }
            return grid[row][col]
        }
        set {
            guard isValidPosition(row: row, col: col) else { return }
            grid[row][col] = newValue
            if newValue != nil {
                grid[row][col]?.row = row
                grid[row][col]?.column = col
            }
        }
    }

    subscript(pos: GridPosition) -> Gem? {
        get { self[pos.row, pos.column] }
        set { self[pos.row, pos.column] = newValue }
    }

    // MARK: - Query

    func isValidPosition(row: Int, col: Int) -> Bool {
        row >= 0 && row < numRows && col >= 0 && col < numColumns
    }

    func isValidPosition(_ pos: GridPosition) -> Bool {
        isValidPosition(row: pos.row, col: pos.column)
    }

    func isPlayable(row: Int, col: Int) -> Bool {
        isValidPosition(row: row, col: col) && tiles[row][col] != .empty
    }

    func isPlayable(_ pos: GridPosition) -> Bool {
        isPlayable(row: pos.row, col: pos.column)
    }

    func isEmpty(at pos: GridPosition) -> Bool {
        self[pos] == nil
    }

    func tileAt(_ pos: GridPosition) -> TileType {
        guard isValidPosition(pos) else { return .empty }
        return tiles[pos.row][pos.column]
    }

    func blockerAt(_ pos: GridPosition) -> BlockerType? {
        guard isValidPosition(pos) else { return nil }
        return blockers[pos.row][pos.column]
    }

    func hasBlocker(at pos: GridPosition) -> Bool {
        blockerAt(pos) != nil
    }

    // MARK: - Mutation

    func setGem(_ gem: Gem, at pos: GridPosition) {
        guard isValidPosition(pos) else { return }
        var placed = gem
        placed.row = pos.row
        placed.column = pos.column
        grid[pos.row][pos.column] = placed
    }

    func removeGem(at pos: GridPosition) {
        guard isValidPosition(pos) else { return }
        grid[pos.row][pos.column] = nil
    }

    func setBlocker(_ blocker: BlockerType?, at pos: GridPosition) {
        guard isValidPosition(pos) else { return }
        blockers[pos.row][pos.column] = blocker
    }

    func setTile(_ tile: TileType, at pos: GridPosition) {
        guard isValidPosition(pos) else { return }
        tiles[pos.row][pos.column] = tile
    }

    func swapGems(_ posA: GridPosition, _ posB: GridPosition) {
        let gemA = self[posA]
        let gemB = self[posB]
        if var a = gemA {
            a.row = posB.row
            a.column = posB.column
            grid[posB.row][posB.column] = a
        } else {
            grid[posB.row][posB.column] = nil
        }
        if var b = gemB {
            b.row = posA.row
            b.column = posA.column
            grid[posA.row][posA.column] = b
        } else {
            grid[posA.row][posA.column] = nil
        }
    }

    // MARK: - Iteration

    func allPositions() -> [GridPosition] {
        var positions: [GridPosition] = []
        for row in 0..<numRows {
            for col in 0..<numColumns {
                positions.append(GridPosition(row: row, column: col))
            }
        }
        return positions
    }

    func allPlayablePositions() -> [GridPosition] {
        allPositions().filter { isPlayable($0) }
    }

    func allGems() -> [Gem] {
        var gems: [Gem] = []
        for row in 0..<numRows {
            for col in 0..<numColumns {
                if let gem = grid[row][col] {
                    gems.append(gem)
                }
            }
        }
        return gems
    }

    // MARK: - Ore Vein Management

    func hasOreVein(at pos: GridPosition) -> Bool {
        guard isValidPosition(pos) else { return false }
        let tile = tiles[pos.row][pos.column]
        return tile == .oreVein || tile == .doubleOre
    }

    func clearOreLayer(at pos: GridPosition) -> Bool {
        guard isValidPosition(pos) else { return false }
        switch tiles[pos.row][pos.column] {
        case .doubleOre:
            tiles[pos.row][pos.column] = .oreVein
            return false // Not fully cleared
        case .oreVein:
            tiles[pos.row][pos.column] = .normal
            return true  // Fully cleared
        default:
            return false
        }
    }

    // MARK: - Copy

    func copy() -> Board {
        let newBoard = Board(numRows: numRows, numColumns: numColumns)
        for row in 0..<numRows {
            for col in 0..<numColumns {
                newBoard.grid[row][col] = grid[row][col]
                newBoard.tiles[row][col] = tiles[row][col]
                newBoard.blockers[row][col] = blockers[row][col]
            }
        }
        return newBoard
    }
}
