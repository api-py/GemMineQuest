import Foundation

struct MatchResult: Equatable {
    let positions: Set<GridPosition>
    let pattern: MatchPattern
    let color: GemColor
    let specialPosition: GridPosition?  // Where the special gem should be created
    let specialType: SpecialType?       // What special gem to create

    var count: Int { positions.count }

    init(positions: Set<GridPosition>, pattern: MatchPattern, color: GemColor,
         specialPosition: GridPosition? = nil, specialType: SpecialType? = nil) {
        self.positions = positions
        self.pattern = pattern
        self.color = color
        self.specialPosition = specialPosition
        self.specialType = specialType
    }

    static func specialFor(pattern: MatchPattern, isHorizontal: Bool) -> SpecialType? {
        switch pattern {
        case .three: return nil
        case .four: return isHorizontal ? .laserVertical : .laserHorizontal
        case .lShape, .tShape: return .volatile
        case .five: return .crystalBall
        case .square: return .miningDrone
        }
    }
}
