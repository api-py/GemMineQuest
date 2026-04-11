import SwiftUI
import SpriteKit

@MainActor
class GameViewModel: ObservableObject {
    let levelNumber: Int
    @Published var showGameOver = false
    @Published var didWin = false
    @Published var stars = 0
    @Published var finalScore = 0
    @Published var sceneReady = false
    @Published var retryCount = 0
    @Published var godModeEnabled = false {
        didSet {
            scene?.godModeEnabled = godModeEnabled
            scene?.gameState?.godModeEnabled = godModeEnabled
            if let state = scene?.gameState {
                scene?.hud?.updateMoves(state.movesRemaining, godMode: godModeEnabled)
            }
            showGodModeToast = true
        }
    }
    @Published var showGodModeToast = false

    private(set) var scene: GameScene?

    init(levelNumber: Int) {
        self.levelNumber = levelNumber
    }

    func createScene(size: CGSize, godMode: Bool) -> GameScene {
        if let existing = scene { return existing }

        // Guard against zero size to prevent CAMetalLayer warning
        guard size.width > 0 && size.height > 0 else {
            let fallback = GameScene(size: CGSize(width: 390, height: 844))
            fallback.scaleMode = .resizeFill
            return fallback
        }

        let state = LevelGenerator.createGameState(levelNumber: levelNumber)
        let engine = GameEngine(state: state)
        self.godModeEnabled = godMode
        state.godModeEnabled = godMode

        let scene = GameScene(size: size)
        scene.scaleMode = .resizeFill
        scene.godModeEnabled = godMode
        scene.configure(state: state, engine: engine)
        scene.gameSceneDelegate = self
        self.scene = scene
        self.sceneReady = true
        refreshDisplay()
        return scene
    }

    func retryLevel() {
        showGameOver = false
        didWin = false
        stars = 0
        finalScore = 0
        scene = nil
        sceneReady = false
        retryCount += 1  // Forces SwiftUI view rebuild
    }

    func continueWithMoves(_ count: Int) {
        guard let state = scene?.gameState else { return }
        state.isFailed = false
        state.movesRemaining += count
        showGameOver = false
        refreshDisplay()
        // If objectives are already met (e.g. score reached before buying moves), complete immediately
        if state.checkObjectives() {
            scene?.triggerLevelComplete()
        }
    }

    var nextLevelNumber: Int { levelNumber + 1 }

    // Display properties for SwiftUI overlay
    @Published var displayScore: Int = 0
    @Published var displayMoves: Int = 0
    @Published var displayObjective: String = ""
    @Published var objectiveProgressData: [(current: Int, target: Int)] = []

    func refreshDisplay() {
        guard let state = scene?.gameState else { return }
        displayScore = state.score
        displayMoves = state.movesRemaining

        var texts: [String] = []
        var progressData: [(current: Int, target: Int)] = []

        for obj in state.level.objectives {
            switch obj {
            case .reachScore(let target):
                texts.append("Score: \(state.score)/\(target)")
                progressData.append((current: state.score, target: target))
            case .clearAllOre:
                texts.append("Ore: \(state.oreCleared)/\(state.totalOre)")
                progressData.append((current: state.oreCleared, target: state.totalOre))
            case .dropTreasures(let count):
                texts.append("Treasure: \(state.treasuresDropped)/\(count)")
                progressData.append((current: state.treasuresDropped, target: count))
            case .collectGems(let color, let count):
                let collected = state.gemsCollected[color] ?? 0
                texts.append("\(color.displayName): \(collected)/\(count)")
                progressData.append((current: collected, target: count))
            case .collectSpecials(let type, let count):
                let collected = state.specialsCollected[type] ?? 0
                texts.append("\(type.displayName): \(collected)/\(count)")
                progressData.append((current: collected, target: count))
            }
        }

        displayObjective = texts.joined(separator: " | ")
        objectiveProgressData = progressData
    }
}

extension GameViewModel: GameSceneDelegate {
    nonisolated func gameDidComplete(stars: Int, score: Int) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.didWin = true
            self.stars = stars
            self.finalScore = score
            self.showGameOver = true
        }
    }

    nonisolated func gameDidFail() {
        Task { @MainActor [weak self] in
            self?.didWin = false
            self?.showGameOver = true
        }
    }

    nonisolated func scoreDidUpdate(to score: Int) {
        Task { @MainActor [weak self] in self?.refreshDisplay() }
    }
    nonisolated func movesDidUpdate(to moves: Int) {
        Task { @MainActor [weak self] in self?.refreshDisplay() }
    }
}
