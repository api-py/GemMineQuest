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

}
