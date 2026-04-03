import Foundation

enum BlockerType: Codable, Equatable {
    case granite(layers: Int)   // Multi-layer stone (1-3), cracks per adjacent match
    case boulder                // Blocks tile, cleared by adjacent match
    case cage                   // Locks a gem, freed by matching the gem
    case lava                   // Spreads each turn, cleared by adjacent match
    case tnt(countdown: Int)    // Countdown bomb, game over if reaches 0
    case amber                  // Encases gem, freed by adjacent or special
}
