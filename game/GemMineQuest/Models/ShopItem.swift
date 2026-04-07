import Foundation

struct ShopItem: Identifiable {
    let id: String
    let boosterType: BoosterType
    let quantity: Int
    let price: Int  // in coins
    let displayName: String
    let localizationKey: String
    let iconName: String  // SF Symbol

    func localizedDisplayName(_ lm: LocalizationManager) -> String {
        lm.t(localizationKey)
    }

    static let catalog: [ShopItem] = [
        ShopItem(id: "pickaxe_3", boosterType: .pickaxe, quantity: 3, price: 1000, displayName: "Pickaxe x3", localizationKey: "shopItem.pickaxe3", iconName: "hammer.fill"),
        ShopItem(id: "pickaxe_10", boosterType: .pickaxe, quantity: 10, price: 2800, displayName: "Pickaxe x10", localizationKey: "shopItem.pickaxe10", iconName: "hammer.fill"),
        ShopItem(id: "dynamite_1", boosterType: .dynamite, quantity: 1, price: 1500, displayName: "Dynamite", localizationKey: "shopItem.dynamite1", iconName: "flame.fill"),
        ShopItem(id: "dynamite_5", boosterType: .dynamite, quantity: 5, price: 6000, displayName: "Dynamite x5", localizationKey: "shopItem.dynamite5", iconName: "flame.fill"),
        ShopItem(id: "drone_1", boosterType: .droneStrike, quantity: 1, price: 2000, displayName: "Drone Strike", localizationKey: "shopItem.drone1", iconName: "scope"),
        ShopItem(id: "drone_3", boosterType: .droneStrike, quantity: 3, price: 5000, displayName: "Drone x3", localizationKey: "shopItem.drone3", iconName: "scope"),
        ShopItem(id: "forge_1", boosterType: .gemForge, quantity: 1, price: 2500, displayName: "Gem Forge", localizationKey: "shopItem.forge1", iconName: "sparkles"),
        ShopItem(id: "forge_3", boosterType: .gemForge, quantity: 3, price: 6500, displayName: "Forge x3", localizationKey: "shopItem.forge3", iconName: "sparkles"),
        ShopItem(id: "cart_1", boosterType: .mineCartRush, quantity: 1, price: 3000, displayName: "Mine Cart", localizationKey: "shopItem.cart1", iconName: "tram.fill"),
    ]
}
