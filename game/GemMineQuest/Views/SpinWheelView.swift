import SwiftUI

struct SpinWheelView: View {
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var boosterInventory: BoosterInventory
    var onDismiss: () -> Void

    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var showResult = false
    @State private var wonPrize: SpinPrize?

    private let segments: [SpinPrize] = [
        SpinPrize(label: "50 Coins", coins: 50, gems: 0, booster: nil),
        SpinPrize(label: "Pickaxe", coins: 0, gems: 0, booster: .pickaxe),
        SpinPrize(label: "100 Coins", coins: 100, gems: 0, booster: nil),
        SpinPrize(label: "Dynamite", coins: 0, gems: 0, booster: .dynamite),
        SpinPrize(label: "2 Gems", coins: 0, gems: 2, booster: nil),
        SpinPrize(label: "Drone", coins: 0, gems: 0, booster: .droneStrike),
        SpinPrize(label: "200 Coins", coins: 200, gems: 0, booster: nil),
        SpinPrize(label: "Gem Forge", coins: 0, gems: 0, booster: .gemForge)
    ]

    private let segmentColors: [UInt32] = [
        0xD41818, 0xC9A84C, 0x8B0000, 0xE8A035,
        0xD41818, 0xC9A84C, 0x8B0000, 0xE8A035
    ]

    var body: some View {
        ZStack {
            // Dark overlay
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {}

            VStack(spacing: 20) {
                Spacer()

                // Title
                Text("LUCKY MINE SPIN")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [Color(hex: 0xFFD700), Color(hex: 0xE8A035)],
                                       startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: Color(hex: 0xFFD700).opacity(0.4), radius: 8)

                // Wheel
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(
                            LinearGradient(colors: [Color(hex: 0xFFD700), Color(hex: 0xC9A84C)],
                                           startPoint: .top, endPoint: .bottom),
                            lineWidth: 6
                        )
                        .frame(width: 280, height: 280)

                    // Segments
                    ForEach(0..<8, id: \.self) { index in
                        WheelSegment(
                            index: index,
                            total: 8,
                            label: segments[index].label,
                            color: Color(hex: segmentColors[index])
                        )
                    }
                    .frame(width: 268, height: 268)
                    .clipShape(Circle())
                    .rotationEffect(.degrees(rotation))

                    // Center circle
                    Circle()
                        .fill(
                            LinearGradient(colors: [Color(hex: 0xFFD700), Color(hex: 0xC9A84C)],
                                           startPoint: .top, endPoint: .bottom)
                        )
                        .frame(width: 40, height: 40)
                        .shadow(color: Color(hex: 0xFFD700).opacity(0.5), radius: 6)

                    // Pointer (top)
                    VStack {
                        Triangle()
                            .fill(Color(hex: 0xFFD700))
                            .frame(width: 24, height: 20)
                            .shadow(color: Color(hex: 0xFFD700).opacity(0.5), radius: 4)
                        Spacer()
                    }
                    .frame(height: 280)
                }

                if showResult, let prize = wonPrize {
                    // Result display
                    VStack(spacing: 8) {
                        Text("YOU WON!")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(Color(hex: 0xFFD700))

                        Text(prize.label)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)

                        Button(action: collectPrize) {
                            Text("COLLECT")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: 200)
                                .padding(.vertical, 14)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: 0xD41818), Color(hex: 0x8B0000)],
                                        startPoint: .top, endPoint: .bottom
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .shadow(color: Color(hex: 0xC71414).opacity(0.5), radius: 8, y: 4)
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    // Spin button
                    Button(action: spinWheel) {
                        Text("SPIN!")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: 200)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: isSpinning
                                        ? [Color(hex: 0x4A3520), Color(hex: 0x2A1E10)]
                                        : [Color(hex: 0xD41818), Color(hex: 0x8B0000)],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: Color(hex: 0xC71414).opacity(0.5), radius: 8, y: 4)
                    }
                    .disabled(isSpinning)
                }

                // Close button
                Button(action: onDismiss) {
                    Text("Close")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: 0x8B7355))
                }
                .padding(.top, 8)

                Spacer()
            }
        }
    }

    private func spinWheel() {
        guard !isSpinning else { return }
        isSpinning = true

        let winningIndex = Int.random(in: 0..<8)
        let segmentAngle = 360.0 / 8.0
        // Spin multiple full rotations + land on the winning segment
        // Pointer is at top (0 degrees), segments are drawn clockwise
        let targetAngle = 360.0 * Double(Int.random(in: 4...7)) + (360.0 - segmentAngle * Double(winningIndex) - segmentAngle / 2.0)

        wonPrize = segments[winningIndex]

        withAnimation(.timingCurve(0.2, 0.8, 0.3, 1.0, duration: 4.0)) {
            rotation += targetAngle
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.2) {
            isSpinning = false
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                showResult = true
            }
        }
    }

    private func collectPrize() {
        guard let prize = wonPrize else { return }
        if prize.coins > 0 {
            progressManager.progress.addCoins(prize.coins)
        }
        if prize.gems > 0 {
            progressManager.progress.gems += prize.gems
        }
        if let booster = prize.booster {
            boosterInventory.increment(booster)
        }
        progressManager.recordSpin()
        onDismiss()
    }
}

// MARK: - Supporting Types

struct SpinPrize {
    let label: String
    let coins: Int
    let gems: Int
    let booster: BoosterType?
}

struct WheelSegment: View {
    let index: Int
    let total: Int
    let label: String
    let color: Color

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: size / 2, y: size / 2)
            let radius = size / 2
            let segmentAngle = 360.0 / Double(total)
            let startAngle = Angle(degrees: segmentAngle * Double(index) - 90)
            let endAngle = Angle(degrees: segmentAngle * Double(index + 1) - 90)
            let midAngle = Angle(degrees: segmentAngle * Double(index) + segmentAngle / 2 - 90)

            Path { path in
                path.move(to: center)
                path.addArc(center: center, radius: radius,
                           startAngle: startAngle, endAngle: endAngle, clockwise: false)
                path.closeSubpath()
            }
            .fill(color)

            // Label
            let labelRadius = radius * 0.65
            let labelX = center.x + labelRadius * cos(CGFloat(midAngle.radians))
            let labelY = center.y + labelRadius * sin(CGFloat(midAngle.radians))

            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black, radius: 2)
                .rotationEffect(midAngle + .degrees(90))
                .position(x: labelX, y: labelY)
        }
    }
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
