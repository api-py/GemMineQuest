import SwiftUI

struct EventBannerView: View {
    var onStart: () -> Void
    var onDismiss: () -> Void

    @State private var showContent = true
    @State private var timeRemaining = "25d 22h"

    var body: some View {
        if showContent {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(Color(hex: 0x8B7355))
                    }
                }
                .padding(.trailing, 16)
                .padding(.top, 8)

                HStack(spacing: 14) {
                    // Event icon
                    Image(systemName: "diamond.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Color(hex: 0xFFD700))
                        .shadow(color: Color(hex: 0xFFD700).opacity(0.5), radius: 4)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Gem Hunt")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundColor(.white)

                        Text("Collect gems for bonus rewards!")
                            .font(.caption)
                            .foregroundColor(Color(hex: 0xCCBB99))

                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                                .font(.caption2)
                            Text(timeRemaining)
                                .font(.caption.weight(.bold))
                        }
                        .foregroundColor(Color(hex: 0xFF8C00))
                    }

                    Spacer()

                    // Round badge
                    VStack(spacing: 2) {
                        Text("ROUND")
                            .font(.system(size: 8, weight: .black))
                        Text("1")
                            .font(.system(size: 18, weight: .black))
                    }
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.purple)
                    )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 10)

                Button(action: onStart) {
                    Text("Start")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [Color.green, Color(hex: 0x228B22)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                }
            }
            .background(
                LinearGradient(
                    colors: [Color(hex: 0x2D1B12), Color(hex: 0x1A0F0A)],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: 0xE8A035), Color(hex: 0x6B4F3A)],
                            startPoint: .top, endPoint: .bottom
                        ),
                        lineWidth: 2
                    )
            )
            .padding(.horizontal, 20)
            .shadow(color: .black.opacity(0.3), radius: 8)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}
