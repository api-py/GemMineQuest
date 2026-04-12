import SpriteKit

/// Calculates positions for the game board, adapting to screen size.
/// The board fills the scene with small margins — NO SpriteKit HUD.
/// All game info (score, moves, objectives) is handled by SwiftUI overlay.
struct BoardLayout {
    let numRows: Int
    let numColumns: Int
    let tileSize: CGFloat
    let boardOrigin: CGPoint
    let boardSize: CGSize
    let sceneSize: CGSize

    // Reserve space for SwiftUI overlays (safe area + top bar + bottom booster bar)
    static let topMargin: CGFloat = Constants.isIPad ? 140 : 100
    static let bottomMargin: CGFloat = Constants.isIPad ? 120 : 80

    init(sceneSize: CGSize, numRows: Int = Constants.defaultGridRows, numColumns: Int = Constants.defaultGridColumns) {
        self.sceneSize = sceneSize
        self.numRows = numRows
        self.numColumns = numColumns

        let availableWidth = sceneSize.width - Constants.boardPadding * 2
        let availableHeight = sceneSize.height - Self.topMargin - Self.bottomMargin

        let maxTileW = availableWidth / CGFloat(numColumns)
        let maxTileH = availableHeight / CGFloat(numRows)
        self.tileSize = min(min(maxTileW, maxTileH), Constants.maxGemSize)

        self.boardSize = CGSize(
            width: tileSize * CGFloat(numColumns),
            height: tileSize * CGFloat(numRows)
        )

        // Position board: center horizontally, vertically centered between top bar and booster bar
        let boardX = (sceneSize.width - boardSize.width) / 2
        let verticalPadding = max((availableHeight - boardSize.height) / 2, 0)
        let boardY = Self.bottomMargin + verticalPadding
        self.boardOrigin = CGPoint(x: max(boardX, Constants.boardPadding), y: max(boardY, Self.bottomMargin))
    }

    func positionFor(row: Int, column: Int) -> CGPoint {
        CGPoint(
            x: boardOrigin.x + CGFloat(column) * tileSize + tileSize / 2,
            y: boardOrigin.y + CGFloat(row) * tileSize + tileSize / 2
        )
    }

    func positionFor(_ pos: GridPosition) -> CGPoint {
        positionFor(row: pos.row, column: pos.column)
    }

    func gridPositionFor(point: CGPoint) -> GridPosition? {
        let col = Int((point.x - boardOrigin.x) / tileSize)
        let row = Int((point.y - boardOrigin.y) / tileSize)
        guard row >= 0 && row < numRows && col >= 0 && col < numColumns else { return nil }
        return GridPosition(row: row, column: col)
    }

    var gemSize: CGFloat { tileSize - Constants.gemSpacing * 2 }

    func entryPositionFor(column: Int) -> CGPoint {
        CGPoint(
            x: boardOrigin.x + CGFloat(column) * tileSize + tileSize / 2,
            y: boardOrigin.y + CGFloat(numRows) * tileSize + tileSize
        )
    }
}
