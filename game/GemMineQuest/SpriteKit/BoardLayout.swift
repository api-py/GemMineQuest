import SpriteKit

/// Calculates positions for the game board, adapting to screen size.
struct BoardLayout {
    let numRows: Int
    let numColumns: Int
    let tileSize: CGFloat
    let boardOrigin: CGPoint  // Bottom-left of board
    let boardSize: CGSize
    let sceneSize: CGSize

    init(sceneSize: CGSize, numRows: Int = 8, numColumns: Int = 8) {
        self.sceneSize = sceneSize
        self.numRows = numRows
        self.numColumns = numColumns

        let availableWidth = sceneSize.width - Constants.boardPadding * 2
        let availableHeight = sceneSize.height - Constants.hudHeight - Constants.boardPadding * 3

        let maxTileW = availableWidth / CGFloat(numColumns)
        let maxTileH = availableHeight / CGFloat(numRows)
        self.tileSize = min(min(maxTileW, maxTileH), Constants.maxGemSize)

        self.boardSize = CGSize(
            width: tileSize * CGFloat(numColumns),
            height: tileSize * CGFloat(numRows)
        )

        // Center board horizontally, place below HUD
        let boardX = (sceneSize.width - boardSize.width) / 2
        let boardY = (sceneSize.height - Constants.hudHeight - boardSize.height) / 2
        self.boardOrigin = CGPoint(x: boardX, y: max(boardY, Constants.boardPadding))
    }

    /// Get screen position for a grid position (center of tile)
    func positionFor(row: Int, column: Int) -> CGPoint {
        CGPoint(
            x: boardOrigin.x + CGFloat(column) * tileSize + tileSize / 2,
            y: boardOrigin.y + CGFloat(row) * tileSize + tileSize / 2
        )
    }

    func positionFor(_ pos: GridPosition) -> CGPoint {
        positionFor(row: pos.row, column: pos.column)
    }

    /// Convert screen point to grid position (nil if outside board)
    func gridPositionFor(point: CGPoint) -> GridPosition? {
        let col = Int((point.x - boardOrigin.x) / tileSize)
        let row = Int((point.y - boardOrigin.y) / tileSize)

        guard row >= 0 && row < numRows && col >= 0 && col < numColumns else {
            return nil
        }
        return GridPosition(row: row, column: col)
    }

    /// Gem visual size (slightly smaller than tile for spacing)
    var gemSize: CGFloat {
        tileSize - Constants.gemSpacing * 2
    }

    /// Position for new gems entering from above (for animation start)
    func entryPositionFor(column: Int) -> CGPoint {
        CGPoint(
            x: boardOrigin.x + CGFloat(column) * tileSize + tileSize / 2,
            y: boardOrigin.y + CGFloat(numRows) * tileSize + tileSize
        )
    }

    /// HUD area (above the board)
    var hudOrigin: CGPoint {
        CGPoint(x: sceneSize.width / 2, y: sceneSize.height - Constants.hudHeight / 2 - 10)
    }
}
