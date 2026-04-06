import SwiftUI

struct EventBannerView: View {
    var onStart: () -> Void
    var onDismiss: () -> Void

    @State private var timeRemaining: TimeInterval = 0
    @State private var slideOffset: CGFloat = -300
    @State private var countdownTimer: Timer?

    private var eventTitle: String {
        "Weekend Mining Rush"
    }

    private var eventDescription: String {
        "Double Gold on all levels!"
    }

    // Event ends at midnight Sunday
    private var eventEndDate: Date {
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        components.weekday = 2 // Monday = end of weekend event
        components.hour = 0
        components.minute = 0
        components.second = 0
        if let monday = calendar.date(from: components), monday > now {
            return monday
        }
        // Fallback: 24 hours from now
        return now.addingTimeInterval(86400)
    }

    private var countdownText: String {
        let hours = Int(timeRemaining) / 3600
        let minutes = (Int(timeRemaining) % 3600) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    var body: some View {
        VStack {
            HStack(spacing: 12) {
                // Event icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(colors: [Color(hex: 0xD41818), Color(hex: 0x8B0000)],
                                           startPoint: .top, endPoint: .bottom)
                        )
                        .frame(width: 48, height: 48)

                    Image(systemName: "hammer.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: 0xFFD700))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(eventTitle)
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [Color(hex: 0xFFD700), Color(hex: 0xE8A035)],
                                           startPoint: .leading, endPoint: .trailing)
                        )

                    Text(eventDescription)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: 0xCCBB99))

                    // Countdown
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: 0xFF6347))
                        Text(countdownText)
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(hex: 0xFF6347))
                    }
                }

                Spacer()

                VStack(spacing: 6) {
                    // Start button
                    Button(action: onStart) {
                        Text("Start")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: 0xD41818), Color(hex: 0x8B0000)],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                            .clipShape(Capsule())
                    }

                    // Dismiss
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: 0x6B5A40))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(colors: [Color(hex: 0x2A1E10), Color(hex: 0x1A1208)],
                                       startPoint: .top, endPoint: .bottom)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: 0xC9A84C).opacity(0.3), lineWidth: 1.5)
                    )
                    .shadow(color: Color.black.opacity(0.4), radius: 8, y: 4)
            )
            .padding(.horizontal, 16)
            .offset(y: slideOffset)

            Spacer()
        }
        .allowsHitTesting(slideOffset >= -10)
        .onAppear {
            updateTimer()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.5)) {
                slideOffset = 60
            }
            // Start countdown timer (stored for cleanup)
            countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                updateTimer()
                if timeRemaining <= 0 {
                    timer.invalidate()
                    onDismiss()
                }
            }
        }
        .onDisappear {
            countdownTimer?.invalidate()
            countdownTimer = nil
        }
    }

    private func updateTimer() {
        timeRemaining = max(0, eventEndDate.timeIntervalSince(Date()))
    }
}
