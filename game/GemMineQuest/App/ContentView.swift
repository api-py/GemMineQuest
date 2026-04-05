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
    @State private var currentScreen: AppScreen = .menu
    @State private var selectedLevel: Int?

    // Engagement overlay states
    @State private var showDailyReward = false
    @State private var showSpinWheel = false
    @State private var showMilestone: String? = nil
    @State private var showAchievementToast: Achievement? = nil
    @State private var showEventBanner = false

    var body: some View {
        ZStack {
            // Main navigation
            switch currentScreen {
            case .menu:
                MainMenuView(
                    onPlay: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen = .levelMap
                        }
                    },
                    onSettings: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen = .settings
                        }
                    }
                )
                .transition(.opacity)

            case .levelMap:
                let vm = LevelMapViewModel(progressManager: progressManager)
                LevelMapView(
                    viewModel: vm,
                    onSelectLevel: { level in
                        selectedLevel = level
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen = .levelDetail(level)
                        }
                    },
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen = .menu
                        }
                    },
                    onSpinWheel: {
                        showSpinWheel = true
                    }
                )
                .transition(.move(edge: .trailing))
                .onAppear {
                    checkMilestones()
                }

            case .levelDetail(let level):
                LevelDetailSheet(
                    levelNumber: level,
                    onPlay: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen = .game(level)
                        }
                    },
                    onDismiss: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen = .levelMap
                        }
                    }
                )
                .transition(.move(edge: .bottom))

            case .game(let level):
                GameContainerView(
                    levelNumber: level,
                    onDismiss: {
                        checkPostGameAchievements()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen = .levelMap
                        }
                    },
                    onNextLevel: { nextLevel in
                        checkPostGameAchievements()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen = .game(nextLevel)
                        }
                    }
                )
                .transition(.opacity)

            case .settings:
                SettingsView(
                    onDismiss: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen = .menu
                        }
                    }
                )
                .transition(.move(edge: .trailing))
            }

            // MARK: - Engagement Overlays (ZStack on top of everything)

            // Daily reward popup
            if showDailyReward {
                DailyRewardView(onDismiss: {
                    withAnimation {
                        showDailyReward = false
                        // Show event banner after daily reward
                        showEventBanner = true
                    }
                })
                .transition(.opacity)
                .zIndex(100)
            }

            // Spin wheel
            if showSpinWheel {
                SpinWheelView(onDismiss: {
                    withAnimation {
                        showSpinWheel = false
                    }
                })
                .transition(.opacity)
                .zIndex(100)
            }

            // Milestone popup
            if let milestone = showMilestone {
                MilestonePopupView(milestoneId: milestone, onDismiss: {
                    progressManager.claimMilestone(milestone)
                    withAnimation {
                        showMilestone = nil
                    }
                    // Check for more milestones
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        checkMilestones()
                    }
                })
                .transition(.opacity)
                .zIndex(100)
            }

            // Achievement toast
            if let achievement = showAchievementToast {
                AchievementToastView(achievement: achievement, onDismiss: {
                    withAnimation {
                        showAchievementToast = nil
                    }
                })
                .zIndex(200)
            }

            // Event banner (shown at top of level map)
            if showEventBanner && currentScreen == .levelMap {
                VStack {
                    EventBannerView(
                        onStart: {
                            withAnimation { showEventBanner = false }
                        },
                        onDismiss: {
                            withAnimation { showEventBanner = false }
                        }
                    )
                    .padding(.top, 80)

                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(50)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentScreen)
        .onAppear {
            // Request notification permission on first launch
            NotificationManager.shared.requestPermission()

            // Check daily reward
            if progressManager.hasDailyReward() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        showDailyReward = true
                    }
                }
            }
        }
    }

    // MARK: - Engagement Checks

    private func checkMilestones() {
        let milestones = progressManager.checkMilestones()
        if let first = milestones.first {
            withAnimation {
                showMilestone = first
            }
        }
    }

    private func checkPostGameAchievements() {
        let newAchievements = progressManager.checkAchievements()
        if let first = newAchievements.first {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    showAchievementToast = first
                }
            }
        }
    }
}
