import Foundation

enum TileType: Int, Codable, Equatable {
    case empty = 0        // No tile - gap in the board
    case normal = 1       // Standard tile
    case oreVein = 2      // Single-layer ore (like jelly)
    case doubleOre = 3    // Double-layer ore
    case mineCart = 4     // Exit point for treasure drops (at bottom)
}
