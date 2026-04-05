import SwiftUI

struct LevelMapView: View {
    @ObservedObject var viewModel: LevelMapViewModel
    @EnvironmentObject var progressManager: ProgressManager
    var onSelectLevel: (Int) -> Void
    var onBack: () -> Void
    var onSpinWheel: (() -> Void)? = nil
    @State private var showLockedAlert = false
    @State private var spinPulse: CGFloat = 1.0
    @Environment(\.horizontalSizeClass) var sizeClass

    private var nodeSize: CGFloat { sizeClass == .regular ? 90 : 76 }
    private var verticalSpacing: CGFloat { sizeClass == .regular ? 24 : 14 }
    private var horizontalPadding: CGFloat { sizeClass == .regular ? 100 : 40 }
    private var fontSize: CGFloat { sizeClass == .regular ? 30 : 26 }
    private var nameFontSize: CGFloat { sizeClass == .regular ? 14 : 12 }

    var body: some View {
        VStack(spacing: 0) {
            // HEADER
            HStack {
                Button(action: onBack) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: 0xC71414))
                            .frame(width: 44, height: 44)
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                Spacer()

                Text("Mine Shaft")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: 0xFFD700))

                Spacer()

                // Coin counter
                HStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: 0xFFD700))
                    Text("\(progressManager.progress.coins)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: 0xFFD700))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.4))
                        .overlay(Capsule().stroke(Color(hex: 0xC9A84C).opacity(0.25), lineWidth: 0.5))
                )
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 8)
            .background(Color(hex: 0x0F0A05).opacity(0.95))

            // SCROLLABLE LEVEL LIST
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: true) {
                    ZStack {
                        // Track connections between levels
                        TrackConnectionsView(
                            levels: viewModel.levels,
                            nodeSize: nodeSize,
                            verticalSpacing: verticalSpacing,
                            horizontalPadding: horizontalPadding
                        )

                        // Level nodes
                        VStack(spacing: 0) {
                            ForEach(viewModel.levels.reversed()) { level in
                                LevelNodeView(
                                    item: level,
                                    nodeSize: nodeSize,
                                    fontSize: fontSize,
                                    nameFontSize: nameFontSize,
                                    horizontalPadding: horizontalPadding,
                                    verticalSpacing: verticalSpacing
                                )
                                .id(level.number)
                                .onTapGesture {
                                    if level.isUnlocked {
                                        onSelectLevel(level.number)
                                    } else {
                                        showLockedAlert = true
                                    }
                                }
                            }
                        }
                        .padding(.top, 10)
                    }
                    .padding(.bottom, 150)
                }
                .onAppear {
                    viewModel.refreshLevels()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation {
                            proxy.scrollTo(viewModel.currentLevel, anchor: .center)
                        }
                    }
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if let spinAction = onSpinWheel {
                Button(action: spinAction) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [Color(hex: 0xE8A035), Color(hex: 0xC68020)], startPoint: .top, endPoint: .bottom))
                            .frame(width: 60, height: 60)
                            .overlay(Circle().stroke(Color(hex: 0xFFD700), lineWidth: 2))
                            .shadow(color: Color(hex: 0xE8A035).opacity(0.4), radius: 8)
                        Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                            .font(.system(size: 22, weight: .bold)).foregroundColor(.white)
                        if progressManager.hasFreeSpin() {
                            Text("FREE").font(.system(size: 8, weight: .black)).foregroundColor(.white)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Capsule().fill(Color.green))
                                .offset(x: 18, y: -22)
                        }
                    }.scaleEffect(spinPulse)
                }.padding(.trailing, 20).padding(.bottom, 20)
            }
        }
        .onAppear {
            if progressManager.hasFreeSpin() {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) { spinPulse = 1.1 }
            }
        }
        .background(MineShaftBackground().ignoresSafeArea())
        .alert("Level Locked", isPresented: $showLockedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Complete the previous levels first to dig deeper into the mine shaft!")
        }
    }
}

// MARK: - Track Connections

struct TrackConnectionsView: View {
    let levels: [LevelMapItem]
    let nodeSize: CGFloat
    let verticalSpacing: CGFloat
    let horizontalPadding: CGFloat

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            Path { path in
                let reversed = levels.reversed()
                let items = Array(reversed)
                for i in 0..<(items.count - 1) {
                    let curr = items[i]
                    let next = items[i + 1]
                    let rowHeight = nodeSize + verticalSpacing + 20
                    let currY = CGFloat(i) * rowHeight + 10 + nodeSize / 2
                    let nextY = CGFloat(i + 1) * rowHeight + 10 + nodeSize / 2
                    let currX = curr.number % 2 == 0
                        ? width - horizontalPadding - nodeSize / 2 + 10
                        : horizontalPadding + nodeSize / 2 - 10
                    let nextX = next.number % 2 == 0
                        ? width - horizontalPadding - nodeSize / 2 + 10
                        : horizontalPadding + nodeSize / 2 - 10
                    path.move(to: CGPoint(x: currX, y: currY))
                    path.addCurve(
                        to: CGPoint(x: nextX, y: nextY),
                        control1: CGPoint(x: currX, y: (currY + nextY) / 2),
                        control2: CGPoint(x: nextX, y: (currY + nextY) / 2)
                    )
                }
            }
            .stroke(
                Color(hex: 0xC9A84C).opacity(0.35),
                style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [8, 6])
            )
        }
    }
}

// MARK: - Mine Shaft Background

struct MineShaftBackground: View {
    var body: some View {
        ZStack {
            Color.black
                .overlay(
                    Group {
                        if let _ = UIImage(named: "bg_level_map") {
                            Image("bg_level_map")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .opacity(0.65)
                        } else {
                            Image("mine_bg_1")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .opacity(0.5)
                        }
                    }
                    .clipped()
                )
                .clipped()
        }
    }
}

// MARK: - Level Node

struct LevelNodeView: View {
    let item: LevelMapItem
    let nodeSize: CGFloat
    let fontSize: CGFloat
    let nameFontSize: CGFloat
    let horizontalPadding: CGFloat
    let verticalSpacing: CGFloat

    private var isCurrent: Bool {
        item.isUnlocked && item.stars == 0
    }

    var body: some View {
        VStack(spacing: verticalSpacing) {
            HStack {
                if item.number % 2 == 0 { Spacer() }

                VStack(spacing: 4) {
                    ZStack {
                        // Glow for unlocked/current levels
                        if item.isUnlocked {
                            Circle()
                                .fill(RadialGradient(
                                    colors: [
                                        (isCurrent ? Color(hex: 0xFFD700) : Color(hex: 0xFFAA00)).opacity(0.3),
                                        .clear
                                    ],
                                    center: .center, startRadius: nodeSize * 0.2, endRadius: nodeSize * 0.9
                                ))
                                .frame(width: nodeSize * 1.6, height: nodeSize * 1.6)
                        }

                        // Outer decorative ring
                        Circle()
                            .stroke(
                                item.isUnlocked
                                    ? LinearGradient(colors: [Color(hex: 0xFFD700), Color(hex: 0xC9A84C)],
                                                     startPoint: .top, endPoint: .bottom)
                                    : LinearGradient(colors: [Color(hex: 0x4A3520), Color(hex: 0x2A1E10)],
                                                     startPoint: .top, endPoint: .bottom),
                                lineWidth: 3.5
                            )
                            .frame(width: nodeSize + 4, height: nodeSize + 4)

                        // Main circle
                        Circle()
                            .fill(item.isUnlocked
                                  ? LinearGradient(colors: [Color(hex: 0xD41818), Color(hex: 0x8B0000)],
                                                   startPoint: .top, endPoint: .bottom)
                                  : LinearGradient(colors: [Color(hex: 0x3A2E20), Color(hex: 0x1A1208)],
                                                   startPoint: .top, endPoint: .bottom))
                            .frame(width: nodeSize, height: nodeSize)
                            .shadow(color: item.isUnlocked ? Color(hex: 0xC71414).opacity(0.5) : .clear, radius: 10)

                        // Top shine on unlocked
                        if item.isUnlocked {
                            Ellipse()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: nodeSize * 0.6, height: nodeSize * 0.25)
                                .offset(y: -nodeSize * 0.2)
                        }

                        // Number / lock
                        VStack(spacing: 1) {
                            Text("\(item.number)")
                                .font(.system(size: item.isUnlocked ? fontSize : fontSize * 0.65, weight: .black, design: .rounded))
                                .foregroundColor(item.isUnlocked ? .white : Color(hex: 0x6B5A40))
                            if !item.isUnlocked {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: fontSize * 0.3))
                                    .foregroundColor(Color(hex: 0x5A4530))
                            }
                        }
                    }

                    // Name - larger, with background for readability
                    HStack(spacing: 3) {
                        if item.number >= 5 && item.number % 10 == 5 {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: nameFontSize * 0.85))
                                .foregroundColor(Color(hex: 0xFF6347))
                        }
                        Text(WelshPlaceNames.name(for: item.number))
                            .font(.system(size: nameFontSize, weight: .semibold))
                            .foregroundColor(item.isUnlocked ? Color(hex: 0xFFD700) : Color(hex: 0x7A6A50))
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.5))
                    )

                    if item.stars > 0 {
                        StarRatingView(stars: item.stars, size: nodeSize * 0.22)
                    }
                }

                if item.number % 2 != 0 { Spacer() }
            }
            .padding(.horizontal, horizontalPadding)
        }
    }
}
