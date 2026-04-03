import SwiftUI
import SpriteKit

class GameViewModel: ObservableObject {
    let levelNumber: Int
    @Published var showGameOver = false
    @Published var didWin = false
    @Published var stars = 0
    @Published var finalScore = 0

    private(set) var scene: GameScene?
    private var gameState: GameState?
    private var engine: GameEngine?
    private let progressManager: ProgressManager
    private let settingsManager: SettingsManager

    init(levelNumber: Int, progressManager: ProgressManager, settingsManager: SettingsManager) {
        self.levelNumber = levelNumber
        self.progressManager = progressManager
        self.settingsManager = settingsManager
    }

    func createScene(size: CGSize) -> GameScene {
        let state = LevelGenerator.createGameState(levelNumber: levelNumber)
        let engine = GameEngine(state: state)
        self.gameState = state
        self.engine = engine

        let scene = GameScene(size: size)
        scene.scaleMode = .resizeFill
        scene.godModeEnabled = settingsManager.godModeEnabled
        scene.configure(state: state, engine: engine)
        scene.gameSceneDelegate = self
        self.scene = scene

        return scene
    }

    func retryLevel() {
        showGameOver = false
        didWin = false
        stars = 0
        finalScore = 0
        scene = nil
    }

    var nextLevelNumber: Int {
        levelNumber + 1
    }
}

extension GameViewModel: GameSceneDelegate {
    func gameDidComplete(stars: Int, score: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.didWin = true
            self.stars = stars
            self.finalScore = score
            self.showGameOver = true
            self.progressManager.saveLevelResult(level: self.levelNumber, stars: stars, score: score)
        }
    }

    func gameDidFail() {
        DispatchQueue.main.async { [weak self] in
            self?.didWin = false
            self?.showGameOver = true
        }
    }

    func scoreDidUpdate(to score: Int) {
        // Handled in scene directly
    }

    func movesDidUpdate(to moves: Int) {
        // Handled in scene directly
    }
}
