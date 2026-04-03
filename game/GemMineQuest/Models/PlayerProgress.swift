import Foundation

struct PlayerProgress: Codable {
    var levelStars: [Int: Int] = [:]     // level number -> stars (1-3)
    var highScores: [Int: Int] = [:]     // level number -> best score
    var highestUnlocked: Int = 1

    func isUnlocked(_ level: Int) -> Bool {
        level <= highestUnlocked
    }

    func stars(for level: Int) -> Int {
        levelStars[level] ?? 0
    }

    func highScore(for level: Int) -> Int {
        highScores[level] ?? 0
    }

    mutating func recordResult(level: Int, stars: Int, score: Int) {
        if stars > (levelStars[level] ?? 0) {
            levelStars[level] = stars
        }
        if score > (highScores[level] ?? 0) {
            highScores[level] = score
        }
        if stars > 0 && level >= highestUnlocked {
            highestUnlocked = level + 1
        }
    }
}
