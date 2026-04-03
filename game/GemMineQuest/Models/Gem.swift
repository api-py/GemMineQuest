import Foundation

struct Gem: Identifiable, Equatable {
    let id: UUID
    var color: GemColor
    var special: SpecialType
    var row: Int
    var column: Int

    var position: GridPosition {
        GridPosition(row: row, column: column)
    }

    init(color: GemColor, special: SpecialType = .none, row: Int, column: Int) {
        self.id = UUID()
        self.color = color
        self.special = special
        self.row = row
        self.column = column
    }

    init(id: UUID = UUID(), color: GemColor, special: SpecialType = .none, row: Int, column: Int) {
        self.id = id
        self.color = color
        self.special = special
        self.row = row
        self.column = column
    }

    var isCrystalBall: Bool {
        special == .crystalBall
    }

    var isSpecial: Bool {
        special != .none
    }
}
