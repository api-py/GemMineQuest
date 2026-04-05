import SwiftUI

enum AppScreen: Hashable {
    case menu
    case levelMap
    case levelDetail(Int)
    case game(Int)
    case settings
}

struct ContentView: View {
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var boosterInventory: BoosterInventory
    @State private var currentScreen: AppScreen = .menu

    var body: some View {
        ZStack {
            switch currentScreen {
            case .menu:
                MainMenuView(
                    onPlay: { withAnimation(.easeInOut(duration: 0.3)) { currentScreen = .levelMap } },
                    onSettings: { withAnimation(.easeInOut(duration: 0.3)) { currentScreen = .settings } }
                )
                .transition(.opacity)

            case .levelMap:
                LevelMapView(
                    viewModel: LevelMapViewModel(progressManager: progressManager, godMode: settingsManager.godModeEnabled),
                    onSelectLevel: { level in
                        withAnimation(.easeInOut(duration: 0.3)) { currentScreen = .levelDetail(level) }
                    },
                    onBack: { withAnimation(.easeInOut(duration: 0.3)) { currentScreen = .menu } }
                )
                .transition(.move(edge: .trailing))

            case .levelDetail(let level):
                LevelDetailSheet(
                    levelNumber: level,
                    onPlay: { withAnimation(.easeInOut(duration: 0.3)) { currentScreen = .game(level) } },
                    onDismiss: { withAnimation(.easeInOut(duration: 0.3)) { currentScreen = .levelMap } }
                )
                .transition(.move(edge: .bottom))

            case .game(let level):
                GameContainerView(
                    levelNumber: level,
                    onDismiss: { withAnimation(.easeInOut(duration: 0.3)) { currentScreen = .levelMap } },
                    onNextLevel: { nextLevel in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen = .levelDetail(nextLevel)
                        }
                    }
                )
                .id(level) // Forces complete recreation for new levels

            case .settings:
                SettingsView(
                    onDismiss: { withAnimation(.easeInOut(duration: 0.3)) { currentScreen = .menu } }
                )
                .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentScreen)
    }
}
