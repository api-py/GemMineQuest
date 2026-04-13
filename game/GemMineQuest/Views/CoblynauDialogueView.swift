import SwiftUI

/// A small Coblynau mine spirit companion that appears on the level map
/// and shows Welsh lore tips or narrative dialogue when tapped.
struct CoblynauDialogueView: View {
    let message: String
    var onDismiss: (() -> Void)? = nil
    private let s = Constants.uiScale

    @State private var bobOffset: CGFloat = 0
    @State private var showBubble = false
    @State private var showExcited = false

    var body: some View {
        VStack(spacing: 4) {
            // Speech bubble
            if showBubble && !message.isEmpty {
                Text(message)
                    .font(.system(size: max(11 * s, 10), weight: .regular, design: .serif))
                    .foregroundColor(Color(hex: 0xCCBB99))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black.opacity(0.85))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(hex: 0xC9A84C).opacity(0.3), lineWidth: 0.5)
                            )
                    )
                    .frame(maxWidth: 200)
                    .transition(.scale.combined(with: .opacity))
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.2)) {
                            showBubble = false
                        }
                        onDismiss?()
                    }
            }

            // Coblynau sprite
            ZStack {
                // Glow
                Circle()
                    .fill(RadialGradient(
                        colors: [Color(hex: 0x88CCFF).opacity(0.2), .clear],
                        center: .center, startRadius: 5, endRadius: 30
                    ))
                    .frame(width: 60 * s, height: 60 * s)

                let spriteName = showExcited ? "coblynau_excited" : (showBubble ? "coblynau_talking" : "coblynau_idle")
                if let _ = UIImage(named: spriteName) {
                    Image(spriteName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48 * s, height: 48 * s)
                } else {
                    // Fallback: system image with miner hat feel
                    Image(systemName: "person.fill")
                        .font(.system(size: 24 * s))
                        .foregroundColor(Color(hex: 0x88CCFF))
                }
            }
            .offset(y: bobOffset)
        }
        .onAppear {
            // Gentle bobbing animation
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                bobOffset = -4
            }
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showExcited = true
                showBubble.toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.2)) {
                    showExcited = false
                }
            }
        }
    }
}

/// A compact Coblynau that sits on the level map near the current level.
struct CoblynauMapSprite: View {
    let levelNumber: Int

    var body: some View {
        CoblynauDialogueView(
            message: WelshLoreTips.tip(for: levelNumber)
        )
    }
}
