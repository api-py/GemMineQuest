import SwiftUI

struct ShopView: View {
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var boosterInventory: BoosterInventory
    @EnvironmentObject var localizationManager: LocalizationManager
    var onDismiss: () -> Void

    #if DEBUG
    @AppStorage("godModeEnabled") private var isGodMode = false
    #else
    private let isGodMode = false
    #endif
    @State private var purchasedItemId: String?
    @State private var showPurchaseFlash = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            // Dark overlay
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {}

            VStack(spacing: 16) {
                Spacer().frame(height: 20)

                // Close button
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Image("btn_close")
                            .resizable()
                            .frame(width: 34, height: 34)
                    }
                }
                .padding(.horizontal, 20)

                // Title
                Text(localizationManager.t("shop.title"))
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [Color(hex: 0xFFD700), Color(hex: 0xE8A035)],
                                       startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: Color(hex: 0xFFD700).opacity(0.4), radius: 8)

                // Coin balance
                HStack(spacing: 6) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: 0xFFD700))
                    Text(isGodMode ? "\u{221E}" : "\(progressManager.progress.coins)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: 0xFFD700))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color(hex: 0x2A1E10))
                        .overlay(
                            Capsule()
                                .stroke(Color(hex: 0xC9A84C).opacity(0.3), lineWidth: 1)
                        )
                )

                // Item grid
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(ShopItem.catalog) { item in
                            shopItemCard(item)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 30)
                }
            }
        }
    }

    @ViewBuilder
    private func shopItemCard(_ item: ShopItem) -> some View {
        let canAfford = isGodMode || progressManager.progress.coins >= item.price
        let justPurchased = purchasedItemId == item.id && showPurchaseFlash

        VStack(spacing: 8) {
            // Booster icon
            ZStack {
                Circle()
                    .fill(RadialGradient(
                        colors: [Color(hex: 0xFFD700).opacity(0.15), Color.clear],
                        center: .center, startRadius: 2, endRadius: 30
                    ))
                    .frame(width: 50, height: 50)

                Image(item.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
            }

            // Name
            Text(item.localizedDisplayName(localizationManager))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            // Current stock
            let owned = boosterInventory.count(for: item.boosterType)
            Text(localizationManager.t("shop.owned", owned))
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color(hex: 0x8B7355))

            // Price + BUY button
            Button(action: { purchaseItem(item) }) {
                HStack(spacing: 4) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: 0xFFD700))
                    Text("\(item.price)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        colors: canAfford
                            ? [Color(hex: 0xD41818), Color(hex: 0x8B0000)]
                            : [Color(hex: 0x3D2B1F), Color(hex: 0x2A1E10)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .disabled(!canAfford)
            .opacity(canAfford ? 1.0 : 0.5)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: 0x1A1208))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            justPurchased
                                ? Color(hex: 0x4CAF50).opacity(0.8)
                                : Color(hex: 0xC9A84C).opacity(0.2),
                            lineWidth: justPurchased ? 2 : 1
                        )
                )
        )
        .scaleEffect(justPurchased ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: justPurchased)
    }

    private func purchaseItem(_ item: ShopItem) {
        let success = progressManager.purchaseShopItem(item, boosterInventory: boosterInventory)
        guard success else { return }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            purchasedItemId = item.id
            showPurchaseFlash = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation {
                showPurchaseFlash = false
                purchasedItemId = nil
            }
        }
    }
}
