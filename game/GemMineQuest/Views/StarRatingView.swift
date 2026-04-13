import SwiftUI

struct StarRatingView: View {
    let stars: Int
    let maxStars: Int
    var size: CGFloat = 20

    init(stars: Int, maxStars: Int = 3, size: CGFloat = 20) {
        self.stars = stars
        self.maxStars = maxStars
        self.size = size
    }

    /// Love spoon image names for each star tier (heart=1, key=2, crown=3)
    private static let lovespoonImages = ["lovespoon_heart", "lovespoon_key", "lovespoon_crown"]

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<maxStars, id: \.self) { index in
                let earned = index < stars
                let imageName = Self.lovespoonImages[min(index, Self.lovespoonImages.count - 1)]

                if earned, let _ = UIImage(named: imageName) {
                    // Use love spoon asset for earned stars
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size, height: size)
                        .shadow(color: ColorPalette.uiGold.opacity(0.4), radius: 3)
                } else {
                    // Fallback to system stars
                    Image(systemName: earned ? "star.fill" : "star")
                        .font(.system(size: size))
                        .foregroundColor(earned ? ColorPalette.uiGold : Color.gray.opacity(0.4))
                }
            }
        }
    }
}

// Color(hex:) extension is defined in Extensions.swift
