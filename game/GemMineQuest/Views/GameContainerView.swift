import SwiftUI
import SpriteKit

struct GameContainerView: View {
    let levelNumber: Int
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var boosterInventory: BoosterInventory
    @StateObject private var viewModel: GameViewModel
    var onDismiss: () -> Void
    var onNextLevel: (Int) -> Void

    // Level transition state
    @State private var showTransition = false
    @State private var transitionLevel = 0
    @State private var showExitConfirmation = false
    @State private var showShop = false
    @State private var showObjectiveBanner = false

    init(levelNumber: Int, onDismiss: @escaping () -> Void, onNextLevel: @escaping (Int) -> Void) {
        self.levelNumber = levelNumber
        self.onDismiss = onDismiss
        self.onNextLevel = onNextLevel
        _viewModel = StateObject(wrappedValue: GameViewModel(levelNumber: levelNumber))
    }

    var body: some View {
        ZStack {
            Color(hex: 0x1A0E05).ignoresSafeArea()

            // SpriteKit scene
            GeometryReader { geo in
                SceneHostView(viewModel: viewModel, size: geo.size, godMode: settingsManager.godModeEnabled)
            }
            .ignoresSafeArea()
            .id(viewModel.retryCount)

            // UI overlays
            VStack(spacing: 0) {
                // Top HUD bar - Royal Match style
                HStack(spacing: 0) {
                    // Character portrait with level number (left)
                    VStack(spacing: 2) {
                        if let _ = UIImage(named: "character_miner_king") {
                            Image("character_miner_king")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 48, height: 48)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color(hex: 0xC9A84C), lineWidth: 2))
                                .shadow(color: Color(hex: 0xC9A84C).opacity(0.3), radius: 4)
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 22))
                                .foregroundColor(Color(hex: 0xFFD700))
                                .frame(width: 42, height: 42)
                                .background(Circle().fill(Color(hex: 0x3D2B1F)))
                                .overlay(Circle().stroke(Color(hex: 0xC9A84C), lineWidth: 2))
                        }
                        Text("Lv.\(levelNumber)")
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .foregroundColor(Color(hex: 0xFFD700))
                    }

                    Spacer(minLength: 6)

                    // Goals panel (center) - icon-based objectives with live progress
                    let level = LevelGenerator.getLevel(number: levelNumber)
                    HStack(spacing: 6) {
                        ForEach(level.objectives.indices, id: \.self) { i in
                            let progress = i < viewModel.objectiveProgressData.count
                                ? viewModel.objectiveProgressData[i]
                                : (current: 0, target: 1)
                            ObjectiveIconView(
                                objective: level.objectives[i],
                                current: progress.current,
                                target: progress.target
                            )
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(hex: 0xFFF8E8).opacity(0.95))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color(hex: 0x8B6914).opacity(0.5), lineWidth: 1.5)
                            )
                            .shadow(color: Color.black.opacity(0.2), radius: 4, y: 2)
                    )

                    Spacer(minLength: 6)

                    // Moves badge (right) - large and clear
                    VStack(spacing: 0) {
                        Text("Moves")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: 0x8B7355))
                        Text(viewModel.godModeEnabled ? "\u{221E}" : "\(viewModel.displayMoves)")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(viewModel.displayMoves <= 3 && !viewModel.godModeEnabled
                                ? Color(hex: 0xFF4444) : Color(hex: 0x3D2B1F))
                    }
                    .frame(width: 62, height: 62)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(hex: 0xFFF8E8).opacity(0.95))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        viewModel.displayMoves <= 3 && !viewModel.godModeEnabled
                                            ? Color.red.opacity(0.6)
                                            : Color(hex: 0x8B6914).opacity(0.5),
                                        lineWidth: 1.5
                                    )
                            )
                            .shadow(color: Color.black.opacity(0.2), radius: 4, y: 2)
                    )
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    LinearGradient(
                        colors: [Color(hex: 0x5A1818).opacity(0.95), Color(hex: 0x3D1010).opacity(0.95)],
                        startPoint: .top, endPoint: .bottom
                    )
                )

                // Score bar - prominent display
                HStack(spacing: 8) {
                    // Score with star icon
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: 0xFFD700))
                        Text("\(viewModel.displayScore)")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [Color(hex: 0xFFD700), Color(hex: 0xE8A035)],
                                               startPoint: .top, endPoint: .bottom)
                            )
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.4))
                            .overlay(Capsule().stroke(Color(hex: 0xC9A84C).opacity(0.3), lineWidth: 1))
                    )

                    Spacer()

                    // Shop button
                    Button { showShop = true } label: {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color(hex: 0xFFD700))
                    }

                    // Exit button
                    Button { showExitConfirmation = true } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color(hex: 0xC71414))
                    }

                    // God mode toggle
                    HStack(spacing: 3) {
                        Text("GOD")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(viewModel.godModeEnabled ? Color(hex: 0xFFD700) : Color(hex: 0x6B5A40))
                        Toggle("", isOn: $viewModel.godModeEnabled)
                            .toggleStyle(CompactToggleStyle())
                            .onChange(of: viewModel.godModeEnabled) { _, newValue in
                                settingsManager.godModeEnabled = newValue
                                boosterInventory.godModeActive = newValue
                            }
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.4))
                            .overlay(Capsule().stroke(Color(hex: 0xC9A84C).opacity(0.15), lineWidth: 0.5))
                    )
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color(hex: 0x1A0E05).opacity(0.8))

                // Objective banner on level start
                if showObjectiveBanner {
                    let level = LevelGenerator.getLevel(number: levelNumber)
                    HStack(spacing: 8) {
                        ForEach(level.objectives.indices, id: \.self) { i in
                            if i > 0 {
                                Text("\u{2022}")
                                    .foregroundColor(Color(hex: 0xC9A84C))
                                    .font(.system(size: 14, weight: .bold))
                            }
                            Text(level.objectives[i].displayText)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: 0xFFF8E8))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: 0x1A0E05).opacity(0.85))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: 0xC9A84C).opacity(0.5), lineWidth: 1.5)
                            )
                    )
                    .padding(.top, 8)
                    .transition(.opacity)
                    .allowsHitTesting(false)
                }

                Spacer().allowsHitTesting(false)

                BoosterBarView(
                    inventory: boosterInventory,
                    onBoosterSelected: { booster in
                        guard boosterInventory.use(booster) else { return }
                        switch booster {
                        case .droneStrike:
                            viewModel.scene?.activateDroneStrike()
                        case .mineCartRush:
                            viewModel.scene?.activateMineCartRush()
                        case .gemForge:
                            viewModel.scene?.activateGemForge()
                        case .pickaxe, .dynamite:
                            viewModel.scene?.activeBooster = booster
                        default:
                            break
                        }
                    }
                )
                .padding(.bottom, 8)
            }
            .opacity(showTransition ? 0 : 1)

            // God Mode toast
            if viewModel.showGodModeToast {
                VStack {
                    Text(viewModel.godModeEnabled ? "Unlimited moves ON" : "Unlimited moves OFF")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(
                            viewModel.godModeEnabled
                                ? Color(hex: 0xE8A035).opacity(0.9)
                                : Color(hex: 0x3D2B1F).opacity(0.9)
                        ))
                        .transition(.move(edge: .top).combined(with: .opacity))
                    Spacer().allowsHitTesting(false)
                }
                .padding(.top, 50)
                .allowsHitTesting(false)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation { viewModel.showGodModeToast = false }
                    }
                }
            }

            // Game over overlay
            if viewModel.showGameOver && !showTransition {
                GameOverView(
                    didWin: viewModel.didWin,
                    stars: viewModel.stars,
                    score: viewModel.finalScore,
                    levelNumber: levelNumber,
                    onRetry: {
                        startTransition(text: "Retry — Level \(levelNumber)") {
                            viewModel.retryLevel()
                        }
                    },
                    onNextLevel: {
                        let next = viewModel.nextLevelNumber
                        progressManager.saveLevelResult(
                            level: levelNumber, stars: viewModel.stars, score: viewModel.finalScore
                        )
                        boosterInventory.checkMilestoneReward(levelCompleted: levelNumber)
                        let threeStarCount = progressManager.progress.levelStars.values.filter { $0 >= 3 }.count
                        boosterInventory.checkStarRewards(totalThreeStarLevels: threeStarCount)
                        startTransition(text: "Level \(next) — \(WelshPlaceNames.name(for: next))") {
                            onNextLevel(next)
                        }
                    },
                    onMenu: onDismiss
                )
                .transition(.opacity)
            }

            // Level transition banner
            if showTransition {
                LevelTransitionView(
                    levelNumber: transitionLevel,
                    levelName: WelshPlaceNames.name(for: transitionLevel)
                )
                .transition(.opacity)
            }
        }
        // Show intro banner on first appear
        .onAppear {
            boosterInventory.claimDailyRewardIfNeeded()
            showIntroBanner()
        }
        .onChange(of: viewModel.retryCount) { _, newValue in
            if newValue > 0 {
                showIntroBanner()
            }
        }
        .alert("Leave Game?", isPresented: $showExitConfirmation) {
            Button("Continue Playing", role: .cancel) {}
            Button("Leave", role: .destructive) { onDismiss() }
        } message: {
            Text("Progress on this level will be lost.")
        }
        .fullScreenCover(isPresented: $showShop) {
            ShopView(onDismiss: { showShop = false })
                .environmentObject(progressManager)
                .environmentObject(boosterInventory)
        }
    }

    private func showIntroBanner() {
        transitionLevel = levelNumber
        showTransition = true
        viewModel.scene?.setBoardVisible(false, animated: false)

        // Fade in the board after banner
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showTransition = false
            }
            viewModel.scene?.setBoardVisible(true, animated: true)

            // Show objective banner over the board
            withAnimation(.easeIn(duration: 0.3)) {
                showObjectiveBanner = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showObjectiveBanner = false
                }
            }
        }
    }

    private func startTransition(text: String, completion: @escaping () -> Void) {
        // Extract level number from text for display
        if let num = text.components(separatedBy: " ").compactMap({ Int($0) }).first {
            transitionLevel = num
        } else {
            transitionLevel = levelNumber
        }

        // Phase 1: Fade out board + game over
        viewModel.scene?.setBoardVisible(false, animated: true)
        withAnimation(.easeInOut(duration: 0.4)) {
            showTransition = true
        }

        // Phase 2: After banner holds, trigger the actual navigation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            completion()
        }
    }
}

// MARK: - Level Transition Banner

struct LevelTransitionView: View {
    let levelNumber: Int
    let levelName: String

    @State private var bannerScale: CGFloat = 0.8
    @State private var bannerOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var glowPulse: Bool = false

    var body: some View {
        ZStack {
            Color(hex: 0x040302).ignoresSafeArea()

            // Ambient background glow
            RadialGradient(
                colors: [Color(hex: 0x1A2414).opacity(0.4), Color.clear],
                center: .center, startRadius: 20, endRadius: 250
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {
                Spacer()

                // Lantern glow with pulsing
                ZStack {
                    Circle()
                        .fill(RadialGradient(
                            colors: [Color(hex: 0xFFAA00).opacity(0.18), .clear],
                            center: .center, startRadius: 10, endRadius: 120
                        ))
                        .frame(width: 240, height: 240)
                        .scaleEffect(glowPulse ? 1.05 : 0.95)

                    Image(systemName: "diamond.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: 0xFFD700), Color(hex: 0xE8A035)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .shadow(color: Color(hex: 0xFFD700).opacity(0.4), radius: 10)
                }

                // Level number
                Text("Level \(levelNumber)")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [Color(hex: 0xFFD700), Color(hex: 0xE8A035)],
                                       startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: Color(hex: 0xFFD700).opacity(0.3), radius: 10)
                    .scaleEffect(bannerScale)
                    .opacity(bannerOpacity)

                // Welsh place name
                Text(levelName)
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .foregroundColor(Color(hex: 0xCCBB99))
                    .italic()
                    .opacity(subtitleOpacity)

                // Divider
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, Color(hex: 0xC9A84C).opacity(0.3), Color.clear],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .frame(width: 180, height: 1)
                    .opacity(subtitleOpacity)

                // Objective hint
                let level = LevelGenerator.getLevel(number: levelNumber)
                VStack(spacing: 8) {
                    ForEach(level.objectives.indices, id: \.self) { i in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color(hex: 0xE8A035))
                                .frame(width: 5, height: 5)
                            Text(level.objectives[i].displayText)
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: 0x8B7355))
                        }
                    }
                    Text("\(level.maxMoves) moves")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: 0xE8A035))
                }
                .opacity(subtitleOpacity)
                .padding(.top, 4)

                Spacer()

                Text("Get ready to dig...")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: 0x5A4530))
                    .opacity(subtitleOpacity)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
                bannerScale = 1.0
                bannerOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.5)) {
                subtitleOpacity = 1.0
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }
}

// MARK: - Scene Host

private struct SceneHostView: View {
    @ObservedObject var viewModel: GameViewModel
    let size: CGSize
    let godMode: Bool

    var body: some View {
        if viewModel.sceneReady, let scene = viewModel.scene {
            SpriteView(scene: scene)
                .ignoresSafeArea()
        } else {
            Color(hex: 0x061206)
                .onAppear {
                    let _ = viewModel.createScene(size: size, godMode: godMode)
                }
        }
    }
}

// MARK: - Objective Icon View (Royal Match style)

struct ObjectiveIconView: View {
    let objective: LevelObjective
    let current: Int
    let target: Int

    @State private var showDescription = false

    private var isComplete: Bool { current >= target }

    private var iconName: String {
        switch objective {
        case .reachScore: return "star.fill"
        case .clearAllOre: return "hammer.fill"
        case .dropTreasures: return "shippingbox.fill"
        case .collectGems: return "diamond.fill"
        case .collectSpecials: return "sparkles"
        }
    }

    private var bgColor: Color {
        switch objective {
        case .reachScore: return Color(hex: 0xFFD700)
        case .clearAllOre: return Color(hex: 0x8B6914)
        case .dropTreasures: return Color(hex: 0xE8A035)
        case .collectGems: return Color(hex: 0xC71414)
        case .collectSpecials: return Color(hex: 0x8B00FF)
        }
    }

    private var progressText: String {
        if isComplete { return "\u{2713}" } // checkmark
        switch objective {
        case .reachScore:
            // Show as "2.1k/5k" for readability
            let currentK = current >= 1000 ? "\(current / 1000).\((current % 1000) / 100)k" : "\(current)"
            let targetK = target >= 1000 ? "\(target / 1000)k" : "\(target)"
            return "\(currentK)/\(targetK)"
        default:
            return "\(current)/\(target)"
        }
    }

    private var progressFraction: CGFloat {
        guard target > 0 else { return 0 }
        return min(CGFloat(current) / CGFloat(target), 1.0)
    }

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                // Progress ring background
                Circle()
                    .stroke(Color(hex: 0xDDCCAA), lineWidth: 3)
                    .frame(width: 42, height: 42)

                // Progress ring fill
                Circle()
                    .trim(from: 0, to: progressFraction)
                    .stroke(
                        isComplete ? Color(hex: 0x4CAF50) : bgColor,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 42, height: 42)
                    .rotationEffect(.degrees(-90))

                // Inner circle
                Circle()
                    .fill(isComplete ? Color(hex: 0x4CAF50).opacity(0.15) : bgColor.opacity(0.12))
                    .frame(width: 36, height: 36)

                if isComplete {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: 0x4CAF50))
                } else {
                    Image(systemName: iconName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(bgColor)
                }
            }

            // Progress text below icon
            Text(progressText)
                .font(.system(size: 9, weight: .heavy, design: .rounded))
                .foregroundColor(isComplete ? Color(hex: 0x4CAF50) : Color(hex: 0x5A4530))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(width: 48)
        .onLongPressGesture(minimumDuration: 0.4) {
            showDescription = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                showDescription = false
            }
        }
        .overlay(
            Group {
                if showDescription {
                    Text(objective.descriptionText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: 0xFFF8E8))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: 0x1A0E05).opacity(0.92))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(hex: 0xC9A84C), lineWidth: 1.5)
                                )
                        )
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(width: 180)
                        .offset(y: 60)
                        .transition(.opacity)
                        .onTapGesture { showDescription = false }
                        .zIndex(100)
                }
            }
            , alignment: .top
        )
        .animation(.easeInOut(duration: 0.2), value: showDescription)
    }
}

// MARK: - Toggle Style

struct CompactToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button { configuration.isOn.toggle() } label: {
            RoundedRectangle(cornerRadius: 8)
                .fill(configuration.isOn ? Color(hex: 0xE8A035) : Color(hex: 0x3D2B1F))
                .frame(width: 36, height: 20)
                .overlay(
                    Circle().fill(.white).frame(width: 16, height: 16)
                        .offset(x: configuration.isOn ? 8 : -8)
                        .animation(.easeInOut(duration: 0.15), value: configuration.isOn)
                )
        }
    }
}
