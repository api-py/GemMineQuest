import SwiftUI

struct BoosterBarView: View {
    var onBoosterSelected: (BoosterType) -> Void

    var body: some View {
        HStack(spacing: 16) {
            BoosterButton(icon: "hammer.fill", label: "Pickaxe") {
                onBoosterSelected(.pickaxe)
            }
            BoosterButton(icon: "arrow.left.arrow.right", label: "Swap") {
                onBoosterSelected(.swapCharge)
            }
            BoosterButton(icon: "airplane", label: "Drone") {
                onBoosterSelected(.droneStrike)
            }
            BoosterButton(icon: "tram.fill", label: "Cart") {
                onBoosterSelected(.mineCartRush)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: 0x2D1B12).opacity(0.9))
                .shadow(color: .black.opacity(0.3), radius: 5)
        )
    }
}

struct BoosterButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: 0xE8A035))
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color(hex: 0x3D2B1F))
                    )

                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(Color(hex: 0xCCBB99))
            }
        }
    }
}
