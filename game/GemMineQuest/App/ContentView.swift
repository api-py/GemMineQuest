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

    // Engagement overlay states
    @State private var showDailyReward = false
    @State private var showSpinWheel = false
    @State private var showMilestone: String? = nil
    @State private var showAchievementToast: Achievement? = nil
    @State private var showEventBanner = false

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
                    onBack: { withAnimation(.easeInOut(duration: 0.3)) { currentScreen = .menu } },
                    onSpinWheel: { if progressManager.hasFreeSpin() { showSpinWheel = true } }
                )
                .transition(.move(edge: .trailing))
                .onAppear { checkMilestones() }

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
                    onDismiss: {
                        checkPostGameAchievements()
                        withAnimation(.easeInOut(duration: 0.3)) { currentScreen = .levelMap }
                    },
                    onNextLevel: { nextLevel in
                        checkPostGameAchievements()
                        withAnimation(.easeInOut(duration: 0.3)) { currentScreen = .levelDetail(nextLevel) }
                    }
                )
                .id(level)

            case .settings:
                SettingsView(
                    onDismiss: { withAnimation(.easeInOut(duration: 0.3)) { currentScreen = .menu } }
                )
                .transition(.move(edge: .trailing))
            }

            // MARK: - Engagement Overlays

            if showDailyReward {
                DailyRewardView(onDismiss: {
                    withAnimation { showDailyReward = false; showEventBanner = true }
                }).transition(.opacity).zIndex(100)
            }

            if showSpinWheel {
                SpinWheelView(onDismiss: {
                    withAnimation { showSpinWheel = false }
                }).transition(.opacity).zIndex(100)
            }

            if let milestone = showMilestone {
                MilestonePopupView(milestoneId: milestone, onDismiss: {
                    progressManager.claimMilestone(milestone)
                    withAnimation { showMilestone = nil }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { checkMilestones() }
                }).transition(.opacity).zIndex(100)
            }

            if let achievement = showAchievementToast {
                AchievementToastView(achievement: achievement, onDismiss: {
                    withAnimation { showAchievementToast = nil }
                }).zIndex(200)
            }

            if showEventBanner {
                VStack {
                    EventBannerView(
                        onStart: { withAnimation { showEventBanner = false } },
                        onDismiss: { withAnimation { showEventBanner = false } }
                    ).padding(.top, 80)
                    Spacer()
                }.transition(.move(edge: .top).combined(with: .opacity)).zIndex(50)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentScreen)
        .onAppear {
            NotificationManager.shared.requestPermission()
            if progressManager.hasDailyReward() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation { showDailyReward = true }
                }
            }
        }
    }

    private func checkMilestones() {
        let milestones = progressManager.checkMilestones()
        if let first = milestones.first {
            withAnimation { showMilestone = first }
        }
    }

    private func checkPostGameAchievements() {
        let newAchievements = progressManager.checkAchievements()
        if let first = newAchievements.first {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation { showAchievementToast = first }
            }
        }
    }
}
