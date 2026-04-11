import SwiftUI

struct LanguageSelectionView: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    var onDismiss: () -> Void

    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    @State private var flagsScale: CGFloat = 0.7
    @State private var flagsOpacity: Double = 0
    @State private var englishHover = false
    @State private var welshHover = false

    var body: some View {
        ZStack {
            // Mine-themed background
            Color.black.ignoresSafeArea()
                .overlay(
                    RadialGradient(
                        colors: [Color(hex: 0xFFAA00).opacity(0.08), Color.clear],
                        center: .center, startRadius: 50, endRadius: 350
                    )
                    .ignoresSafeArea()
                )

            VStack(spacing: 0) {
                Spacer()

                // Gem icon
                ZStack {
                    Circle()
                        .fill(RadialGradient(
                            colors: [Color(hex: 0xFFD700).opacity(0.2), Color.clear],
                            center: .center, startRadius: 5, endRadius: 60
                        ))
                        .frame(width: 120, height: 120)

                    Image(systemName: "globe")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: 0xFFD700), Color(hex: 0xE8A035)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .shadow(color: Color(hex: 0xFFD700).opacity(0.4), radius: 8)
                }
                .padding(.bottom, 8)

                // Title (bilingual)
                VStack(spacing: 6) {
                    Text("Choose Your Language")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: 0xFFD700), Color(hex: 0xFF8C00)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )

                    Text("Dewiswch Eich Iaith")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: 0xE8A035))
                }
                .shadow(color: .black.opacity(0.6), radius: 10)
                .scaleEffect(titleScale)
                .opacity(titleOpacity)
                .padding(.bottom, 12)

                Text("Tap a flag to select / Tapiwch faner i ddewis")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: 0x8B7355))
                    .opacity(titleOpacity)
                    .padding(.bottom, 40)

                // Flag buttons
                HStack(spacing: 32) {
                    // English flag
                    Button {
                        localizationManager.setLanguage(.english)
                        withAnimation(.easeInOut(duration: 0.3)) {
                            onDismiss()
                        }
                    } label: {
                        VStack(spacing: 12) {
                            CartoonEnglishFlag()
                                .frame(width: 120, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(hex: 0xFFD700).opacity(0.5), lineWidth: 3)
                                )
                                .shadow(color: Color(hex: 0xFFD700).opacity(0.3), radius: 10)
                                .scaleEffect(englishHover ? 1.08 : 1.0)

                            Text("English")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: 0xFFE8C0))
                        }
                    }
                    .buttonStyle(.plain)
                    .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                        withAnimation(.spring(response: 0.3)) { englishHover = pressing }
                    }, perform: {})

                    // Welsh flag
                    Button {
                        localizationManager.setLanguage(.welsh)
                        withAnimation(.easeInOut(duration: 0.3)) {
                            onDismiss()
                        }
                    } label: {
                        VStack(spacing: 12) {
                            CartoonWelshFlag()
                                .frame(width: 120, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(hex: 0xFFD700).opacity(0.5), lineWidth: 3)
                                )
                                .shadow(color: Color(hex: 0xFFD700).opacity(0.3), radius: 10)
                                .scaleEffect(welshHover ? 1.08 : 1.0)

                            Text("Cymraeg")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: 0xFFE8C0))
                        }
                    }
                    .buttonStyle(.plain)
                    .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                        withAnimation(.spring(response: 0.3)) { welshHover = pressing }
                    }, perform: {})
                }
                .scaleEffect(flagsScale)
                .opacity(flagsOpacity)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                titleScale = 1.0
                titleOpacity = 1.0
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.4)) {
                flagsScale = 1.0
                flagsOpacity = 1.0
            }
        }
    }
}

// MARK: - Cartoon English Flag (Union Jack simplified)

struct CartoonEnglishFlag: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // Blue background
                Rectangle()
                    .fill(Color(red: 0.0, green: 0.2, blue: 0.6))

                // White diagonal stripes
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: w, y: h))
                    path.move(to: CGPoint(x: w, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: h))
                }
                .stroke(Color.white, lineWidth: h * 0.12)

                // Red diagonal stripes (thinner)
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: w, y: h))
                    path.move(to: CGPoint(x: w, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: h))
                }
                .stroke(Color(red: 0.8, green: 0.1, blue: 0.1), lineWidth: h * 0.06)

                // White cross
                Rectangle()
                    .fill(Color.white)
                    .frame(width: w, height: h * 0.22)
                Rectangle()
                    .fill(Color.white)
                    .frame(width: w * 0.22, height: h)

                // Red cross
                Rectangle()
                    .fill(Color(red: 0.8, green: 0.1, blue: 0.1))
                    .frame(width: w, height: h * 0.13)
                Rectangle()
                    .fill(Color(red: 0.8, green: 0.1, blue: 0.1))
                    .frame(width: w * 0.13, height: h)

                // Cartoon shine effect
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.3), Color.clear],
                            startPoint: .top, endPoint: .center
                        )
                    )
                    .frame(width: w * 0.8, height: h * 0.4)
                    .offset(y: -h * 0.18)
            }
        }
    }
}

// MARK: - Cartoon Welsh Flag (Y Ddraig Goch)

struct CartoonWelshFlag: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // Top white half
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.white)
                    Rectangle()
                        .fill(Color(red: 0.0, green: 0.6, blue: 0.2))
                }

                // Cartoon dragon silhouette (simplified)
                ZStack {
                    // Dragon body - a cute simplified dragon shape
                    DragonShape()
                        .fill(Color(red: 0.75, green: 0.1, blue: 0.1))
                        .frame(width: w * 0.55, height: h * 0.55)
                        .shadow(color: Color.red.opacity(0.3), radius: 4)

                    // Dragon eye
                    Circle()
                        .fill(Color(hex: 0xFFD700))
                        .frame(width: w * 0.05, height: w * 0.05)
                        .offset(x: w * 0.08, y: -h * 0.1)
                }

                // Cartoon shine effect
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.25), Color.clear],
                            startPoint: .top, endPoint: .center
                        )
                    )
                    .frame(width: w * 0.8, height: h * 0.35)
                    .offset(y: -h * 0.2)
            }
        }
    }
}

// MARK: - Simplified Dragon Shape

struct DragonShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height

        var path = Path()

        // Body curve (simplified dragon silhouette)
        path.move(to: CGPoint(x: w * 0.15, y: h * 0.55))

        // Tail
        path.addCurve(
            to: CGPoint(x: w * 0.05, y: h * 0.4),
            control1: CGPoint(x: w * 0.08, y: h * 0.55),
            control2: CGPoint(x: w * 0.02, y: h * 0.48)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.0, y: h * 0.25),
            control1: CGPoint(x: w * 0.02, y: h * 0.35),
            control2: CGPoint(x: w * 0.0, y: h * 0.3)
        )

        // Back
        path.addCurve(
            to: CGPoint(x: w * 0.25, y: h * 0.15),
            control1: CGPoint(x: w * 0.05, y: h * 0.18),
            control2: CGPoint(x: w * 0.15, y: h * 0.12)
        )

        // Spikes on back
        path.addLine(to: CGPoint(x: w * 0.30, y: h * 0.05))
        path.addLine(to: CGPoint(x: w * 0.35, y: h * 0.15))
        path.addLine(to: CGPoint(x: w * 0.40, y: h * 0.03))
        path.addLine(to: CGPoint(x: w * 0.45, y: h * 0.13))
        path.addLine(to: CGPoint(x: w * 0.50, y: h * 0.05))
        path.addLine(to: CGPoint(x: w * 0.55, y: h * 0.15))

        // Head
        path.addCurve(
            to: CGPoint(x: w * 0.75, y: h * 0.2),
            control1: CGPoint(x: w * 0.62, y: h * 0.12),
            control2: CGPoint(x: w * 0.70, y: h * 0.14)
        )

        // Snout
        path.addCurve(
            to: CGPoint(x: w * 0.95, y: h * 0.25),
            control1: CGPoint(x: w * 0.82, y: h * 0.18),
            control2: CGPoint(x: w * 0.90, y: h * 0.20)
        )

        // Fire breath hint
        path.addLine(to: CGPoint(x: w * 1.0, y: h * 0.22))
        path.addLine(to: CGPoint(x: w * 0.95, y: h * 0.30))

        // Jaw
        path.addCurve(
            to: CGPoint(x: w * 0.72, y: h * 0.35),
            control1: CGPoint(x: w * 0.88, y: h * 0.32),
            control2: CGPoint(x: w * 0.80, y: h * 0.34)
        )

        // Neck to chest
        path.addCurve(
            to: CGPoint(x: w * 0.65, y: h * 0.55),
            control1: CGPoint(x: w * 0.68, y: h * 0.40),
            control2: CGPoint(x: w * 0.66, y: h * 0.48)
        )

        // Front leg
        path.addLine(to: CGPoint(x: w * 0.68, y: h * 0.75))
        path.addLine(to: CGPoint(x: w * 0.72, y: h * 0.78))
        path.addLine(to: CGPoint(x: w * 0.65, y: h * 0.78))
        path.addLine(to: CGPoint(x: w * 0.58, y: h * 0.60))

        // Belly
        path.addCurve(
            to: CGPoint(x: w * 0.35, y: h * 0.65),
            control1: CGPoint(x: w * 0.50, y: h * 0.65),
            control2: CGPoint(x: w * 0.42, y: h * 0.68)
        )

        // Back leg
        path.addLine(to: CGPoint(x: w * 0.35, y: h * 0.80))
        path.addLine(to: CGPoint(x: w * 0.40, y: h * 0.83))
        path.addLine(to: CGPoint(x: w * 0.32, y: h * 0.83))
        path.addLine(to: CGPoint(x: w * 0.28, y: h * 0.68))

        // Back to tail
        path.addCurve(
            to: CGPoint(x: w * 0.15, y: h * 0.55),
            control1: CGPoint(x: w * 0.22, y: h * 0.65),
            control2: CGPoint(x: w * 0.18, y: h * 0.60)
        )

        path.closeSubpath()

        // Wing
        var wing = Path()
        wing.move(to: CGPoint(x: w * 0.40, y: h * 0.20))
        wing.addCurve(
            to: CGPoint(x: w * 0.25, y: h * 0.0),
            control1: CGPoint(x: w * 0.35, y: h * 0.10),
            control2: CGPoint(x: w * 0.28, y: h * 0.02)
        )
        wing.addCurve(
            to: CGPoint(x: w * 0.55, y: h * 0.10),
            control1: CGPoint(x: w * 0.35, y: h * 0.02),
            control2: CGPoint(x: w * 0.48, y: h * 0.05)
        )
        wing.addCurve(
            to: CGPoint(x: w * 0.65, y: h * 0.0),
            control1: CGPoint(x: w * 0.58, y: h * 0.05),
            control2: CGPoint(x: w * 0.62, y: h * 0.0)
        )
        wing.addCurve(
            to: CGPoint(x: w * 0.60, y: h * 0.20),
            control1: CGPoint(x: w * 0.65, y: h * 0.08),
            control2: CGPoint(x: w * 0.63, y: h * 0.15)
        )
        wing.closeSubpath()

        path.addPath(wing)

        return path
    }
}
