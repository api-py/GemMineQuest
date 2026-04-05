import SwiftUI

struct SpinWheelView: View {
    @EnvironmentObject var progressManager: ProgressManager
    var onDismiss: () -> Void

    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var showResult = false
    @State private var wonPrize: SpinPrize?
    @State private var showContent = false

    private let prizes: [SpinPrize] = [
        SpinPrize(name: "+3 Moves", icon: "figure.walk", booster: nil, coins: 0, gems: 0, color: Color(hex: 0xE8A035)),
        SpinPrize(name: "Pickaxe", icon: "hammer.fill", booster: "pickaxe", coins: 0, gems: 0, color: Color(hex: 0xC68020)),
        SpinPrize(name: "200 Coins", icon: "circle.fill", booster: nil, coins: 200, gems: 0, color: Color(hex: 0xFFD700)),
        SpinPrize(name: "Drone", icon: "airplane", booster: "drone", coins: 0, gems: 0, color: Color(hex: 0x607D8B)),
        SpinPrize(name: "500 Coins", icon: "circle.fill", booster: nil, coins: 500, gems: 0, color: Color(hex: 0xFF8C00)),
        SpinPrize(name: "Cart", icon: "tram.fill", booster: "cart", coins: 0, gems: 0, color: Color(hex: 0x5C4033)),
        SpinPrize(name: "+5 Moves", icon: "figure.walk", booster: nil, coins: 0, gems: 0, color: Color(hex: 0x50C878)),
        SpinPrize(name: "JACKPOT!", icon: "diamond.fill", booster: nil, coins: 0, gems: 1, color: Color(hex: 0x9966CC)),
    ]

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {}

            VStack(spacing: 20) {
                Spacer()

                if showContent {
                    Text("LUCKY MINE WHEEL")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: 0xFFD700), Color(hex: 0xFF8C00)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .black, radius: 4)

                    // Wheel
                    ZStack {
                        // Pointer triangle at top
                        Triangle()
                            .fill(Color.red)
                            .frame(width: 24, height: 20)
                            .offset(y: -145)
                            .zIndex(1)

                        // Wheel circle
                        Canvas { context, size in
                            let center = CGPoint(x: size.width / 2, y: size.height / 2)
                            let radius = min(size.width, size.height) / 2 - 8
                            let segmentAngle = .pi * 2 / Double(prizes.count)

                            for (i, prize) in prizes.enumerated() {
                                let startAngle = Double(i) * segmentAngle - .pi / 2
                                let endAngle = startAngle + segmentAngle

                                var path = Path()
                                path.move(to: center)
                                path.addArc(center: center, radius: radius,
                                           startAngle: .radians(startAngle),
                                           endAngle: .radians(endAngle),
                                           clockwise: false)
                                path.closeSubpath()

                                context.fill(path, with: .color(i % 2 == 0 ? prize.color.opacity(0.8) : prize.color.opacity(0.5)))
                                context.stroke(path, with: .color(.white.opacity(0.3)), lineWidth: 1)
                            }

                            // Center circle
                            let centerR: CGFloat = 20
                            let centerPath = Path(ellipseIn: CGRect(x: center.x - centerR, y: center.y - centerR,
                                                                     width: centerR * 2, height: centerR * 2))
                            context.fill(centerPath, with: .color(Color(hex: 0xE8A035)))
                            context.stroke(centerPath, with: .color(.white), lineWidth: 2)
                        }
                        .frame(width: 280, height: 280)
                        .rotationEffect(.degrees(rotation))

                        // Prize labels overlay
                        ForEach(0..<prizes.count, id: \.self) { i in
                            let angle = Double(i) * (360.0 / Double(prizes.count)) + (180.0 / Double(prizes.count))
                            VStack(spacing: 2) {
                                Image(systemName: prizes[i].icon)
                                    .font(.system(size: 14))
                                Text(prizes[i].name)
                                    .font(.system(size: 8, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2)
                            .offset(y: -90)
                            .rotationEffect(.degrees(angle))
                        }
                        .rotationEffect(.degrees(rotation))
                    }

                    // Result display
                    if showResult, let prize = wonPrize {
                        VStack(spacing: 8) {
                            Text("YOU WON!")
                                .font(.system(size: 20, weight: .black))
                                .foregroundColor(Color(hex: 0xFFD700))

                            HStack {
                                Image(systemName: prize.icon)
                                Text(prize.name)
                            }
                            .font(.title2.weight(.bold))
                            .foregroundColor(.white)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }

                    // Spin / Collect button
                    Button(action: {
                        if showResult {
                            // Collect and dismiss
                            if let prize = wonPrize {
                                if let booster = prize.booster {
                                    progressManager.addBooster(booster)
                                }
                                if prize.coins > 0 {
                                    progressManager.addCoins(prize.coins)
                                }
                                if prize.gems > 0 {
                                    progressManager.progress.gems += prize.gems
                                }
                            }
                            onDismiss()
                        } else if !isSpinning {
                            spin()
                        }
                    }) {
                        Text(showResult ? "COLLECT" : "SPIN!")
                            .font(.title3.weight(.black))
                            .foregroundColor(.white)
                            .frame(maxWidth: 220)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: showResult ?
                                        [Color(hex: 0xE8A035), Color(hex: 0xC68020)] :
                                        [Color.green, Color(hex: 0x228B22)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(radius: 6)
                    }
                    .disabled(isSpinning)
                    .opacity(isSpinning ? 0.5 : 1.0)
                }

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
                showContent = true
            }
        }
    }

    private func spin() {
        isSpinning = true
        progressManager.recordSpin()

        // Pick random prize
        let prizeIndex = Int.random(in: 0..<prizes.count)
        wonPrize = prizes[prizeIndex]

        // Calculate target rotation so prize lands under pointer
        let segmentAngle = 360.0 / Double(prizes.count)
        let prizeAngle = Double(prizeIndex) * segmentAngle + segmentAngle / 2
        let extraSpins = 360.0 * Double(Int.random(in: 5...8))
        let targetRotation = extraSpins + (360.0 - prizeAngle)

        withAnimation(.timingCurve(0.0, 0.6, 0.15, 1.0, duration: 4.5)) {
            rotation += targetRotation
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.6) {
            isSpinning = false
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                showResult = true
            }
        }
    }
}

struct SpinPrize {
    let name: String
    let icon: String
    let booster: String?
    let coins: Int
    let gems: Int
    let color: Color
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
