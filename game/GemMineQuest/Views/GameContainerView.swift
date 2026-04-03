import SwiftUI
import SpriteKit

struct GameContainerView: View {
    let levelNumber: Int
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var settingsManager: SettingsManager
    @StateObject private var viewModel: GameViewModel
    var onDismiss: () -> Void
    var onNextLevel: (Int) -> Void

    init(levelNumber: Int, onDismiss: @escaping () -> Void, onNextLevel: @escaping (Int) -> Void) {
        self.levelNumber = levelNumber
        self.onDismiss = onDismiss
        self.onNextLevel = onNextLevel
        _viewModel = StateObject(wrappedValue: GameViewModel(
            levelNumber: levelNumber,
            progressManager: ProgressManager(),
            settingsManager: SettingsManager()
        ))
    }

    var body: some View {
        ZStack {
            Color(hex: 0x1A0F0A).ignoresSafeArea()

            GeometryReader { geo in
                if let scene = viewModel.scene {
                    SpriteView(scene: scene)
                        .ignoresSafeArea()
                } else {
                    Color.clear
                        .onAppear {
                            let _ = viewModel.createScene(size: geo.size)
                            viewModel.scene?.godModeEnabled = settingsManager.godModeEnabled
                        }
                }
            }

            // Booster bar at bottom
            VStack {
                Spacer()
                BoosterBarView(onBoosterSelected: { booster in
                    viewModel.scene?.activeBooster = booster
                })
                .padding(.bottom, 8)
            }

            // Game over overlay
            if viewModel.showGameOver {
                GameOverView(
                    didWin: viewModel.didWin,
                    stars: viewModel.stars,
                    score: viewModel.finalScore,
                    levelNumber: levelNumber,
                    onRetry: {
                        viewModel.retryLevel()
                    },
                    onNextLevel: {
                        onNextLevel(viewModel.nextLevelNumber)
                    },
                    onMenu: onDismiss
                )
                .transition(.opacity)
            }
        }
    }
}
