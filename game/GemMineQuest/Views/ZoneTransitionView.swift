import SwiftUI

/// Displayed when a player advances into a new mining zone.
/// Shows the zone name, Welsh subtitle, tagline, icon, and narrative text.
struct ZoneTransitionView: View {
    let zone: MiningZone
    @EnvironmentObject var localizationManager: LocalizationManager
    var onContinue: () -> Void

    @State private var opacity: Double = 0
    @State private var iconScale: CGFloat = 0.5

    var body: some View {
        ZStack {
            // Dark overlay background
            Color.black.opacity(0.92).ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                // Zone icon
                ZStack {
                    Circle()
                        .fill(RadialGradient(
                            colors: [zone.accentColor.opacity(0.3), .clear],
                            center: .center, startRadius: 10, endRadius: 80
                        ))
                        .frame(width: 160, height: 160)

                    if let img = UIImage(named: zone.iconName) {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                    } else {
                        Image(systemName: zone.fallbackSystemImage)
                            .font(.system(size: 40))
                            .foregroundColor(zone.accentColor)
                    }
                }
                .scaleEffect(iconScale)

                // "Entering" label
                Text("ENTERING")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(zone.accentColor.opacity(0.7))
                    .tracking(4)

                // Zone name
                Text(localizationManager.t(zone.displayNameKey))
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [zone.accentColor, .white],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.center)

                // Welsh subtitle
                Text(localizationManager.t(zone.welshSubtitleKey))
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .italic()
                    .foregroundColor(zone.accentColor.opacity(0.8))

                // Tagline
                Text(localizationManager.t(zone.taglineKey))
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(hex: 0xCCBB99))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                // Narrative text
                let narrativeKey = "zone.\(zone.rawValue).narrative"
                Text(localizationManager.t(narrativeKey))
                    .font(.system(size: 13, weight: .regular, design: .serif))
                    .italic()
                    .foregroundColor(Color.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.top, 8)

                Spacer()

                // Continue button
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.title3.weight(.bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: 220)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [zone.accentColor, zone.accentColor.opacity(0.6)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
                .padding(.bottom, 50)
            }
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                opacity = 1.0
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2)) {
                iconScale = 1.0
            }
        }
    }
}
