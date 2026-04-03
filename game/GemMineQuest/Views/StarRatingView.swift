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

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<maxStars, id: \.self) { index in
                Image(systemName: index < stars ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundColor(index < stars ? Color(hex: 0xFFD700) : Color.gray.opacity(0.4))
            }
        }
    }
}

extension Color {
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
