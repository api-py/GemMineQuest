import SwiftUI

struct LevelMapView: View {
    @ObservedObject var viewModel: LevelMapViewModel
    @EnvironmentObject var progressManager: ProgressManager
    var onSelectLevel: (Int) -> Void
    var onBack: () -> Void
    var onSpinWheel: () -> Void

    @State private var spinPulse: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: 0x2D1B12), Color(hex: 0x1A0F0A), Color(hex: 0x0D0705)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with coin display
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.bold))
                            .foregroundColor(Color(hex: 0xCCBB99))
                            .padding(12)
                    }

                    Spacer()

                    Text("Mine Shaft")
                        .font(.title2.weight(.bold))
                        .foregroundColor(Color(hex: 0xFFD700))

                    Spacer()

                    // Coin counter
                    HStack(spacing: 4) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: 0xFFD700))
                        Text("\(progressManager.progress.coins)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(hex: 0xFFD700))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color(hex: 0x3D2B1F))
                            .overlay(Capsule().stroke(Color(hex: 0x6B4F3A), lineWidth: 1))
                    )
                    .padding(.trailing, 12)
                }
                .padding(.horizontal)

                // Scrollable level map
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.levels.reversed()) { level in
                                LevelNodeView(item: level)
                                    .id(level.number)
                                    .onTapGesture {
                                        if level.isUnlocked {
                                            onSelectLevel(level.number)
                                        }
                                    }
                            }
                        }
                        .padding(.vertical, 20)
                    }
                    .onAppear {
                        withAnimation {
                            proxy.scrollTo(viewModel.currentLevel, anchor: .center)
                        }
                    }
                }
            }

            // Floating spin wheel button (bottom-right)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: onSpinWheel) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: 0xE8A035), Color(hex: 0xC68020)],
                                        startPoint: .top, endPoint: .bottom
                                    )
                                )
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Circle()
                                        .stroke(Color(hex: 0xFFD700), lineWidth: 2)
                                )
                                .shadow(color: Color(hex: 0xE8A035).opacity(0.4), radius: 8)

                            Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)

                            // FREE badge
                            if progressManager.hasFreeSpin() {
                                Text("FREE")
                                    .font(.system(size: 8, weight: .black))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(Color.green))
                                    .offset(x: 18, y: -22)
                            }
                        }
                        .scaleEffect(spinPulse)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            if progressManager.hasFreeSpin() {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    spinPulse = 1.1
                }
            }
        }
    }
}

struct LevelNodeView: View {
    let item: LevelMapItem

    var body: some View {
        HStack {
            // Alternating left/right positioning for snake path
            if item.number % 2 == 0 {
                Spacer()
            }

            VStack(spacing: 4) {
                // Level circle
                ZStack {
                    Circle()
                        .fill(item.isUnlocked ?
                              LinearGradient(colors: [Color(hex: 0xE8A035), Color(hex: 0xC68020)],
                                             startPoint: .top, endPoint: .bottom) :
                              LinearGradient(colors: [Color(hex: 0x3D2B1F), Color(hex: 0x2D1B12)],
                                             startPoint: .top, endPoint: .bottom))
                        .frame(width: 56, height: 56)
                        .overlay(
                            Circle()
                                .stroke(item.isUnlocked ? Color(hex: 0xFFD700).opacity(0.5) : Color(hex: 0x6B4F3A), lineWidth: 1.5)
                        )
                        .shadow(color: item.isUnlocked ? Color(hex: 0xE8A035).opacity(0.3) : .clear,
                                radius: 5)

                    if item.isUnlocked {
                        Text("\(item.number)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: 0x6B4F3A))
                    }
                }

                // Stars
                if item.stars > 0 {
                    StarRatingView(stars: item.stars, size: 12)
                }
            }
            .padding(.vertical, 8)

            if item.number % 2 != 0 {
                Spacer()
            }
        }
        .padding(.horizontal, 60)

        // Connecting line
        Rectangle()
            .fill(Color(hex: 0x6B4F3A).opacity(0.3))
            .frame(width: 2, height: 20)
    }
}
