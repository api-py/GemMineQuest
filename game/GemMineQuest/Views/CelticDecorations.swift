import SwiftUI

/// Reusable Celtic-themed decorative elements for the Welsh mining game UI.

// MARK: - Celtic Border Modifier

/// Applies a Celtic knotwork border around content using image assets.
struct CelticBorderModifier: ViewModifier {
    var cornerSize: CGFloat = 32
    var gold: Bool = true

    func body(content: Content) -> some View {
        content.overlay(
            ZStack {
                // Corner ornaments (if asset available)
                if let _ = UIImage(named: "celtic_corner_ornament") {
                    // Top-left
                    Image("celtic_corner_ornament")
                        .resizable()
                        .frame(width: cornerSize, height: cornerSize)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    // Top-right (mirrored)
                    Image("celtic_corner_ornament")
                        .resizable()
                        .frame(width: cornerSize, height: cornerSize)
                        .scaleEffect(x: -1, y: 1)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    // Bottom-left (mirrored)
                    Image("celtic_corner_ornament")
                        .resizable()
                        .frame(width: cornerSize, height: cornerSize)
                        .scaleEffect(x: 1, y: -1)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    // Bottom-right (mirrored both)
                    Image("celtic_corner_ornament")
                        .resizable()
                        .frame(width: cornerSize, height: cornerSize)
                        .scaleEffect(x: -1, y: -1)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                } else {
                    // Fallback: simple gold/silver rounded border
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            LinearGradient(
                                colors: gold
                                    ? [Color(hex: 0xC9A84C), Color(hex: 0x8B6914)]
                                    : [Color(hex: 0xA0A0B0), Color(hex: 0x6A6A7A)],
                                startPoint: .top, endPoint: .bottom
                            ),
                            lineWidth: 2
                        )
                }
            }
        )
    }
}

extension View {
    /// Adds a Celtic knotwork border decoration.
    func celticBorder(cornerSize: CGFloat = 32, gold: Bool = true) -> some View {
        modifier(CelticBorderModifier(cornerSize: cornerSize, gold: gold))
    }
}

// MARK: - Triskele View

/// A Celtic triple spiral (triskele) symbol.
struct TriskeleView: View {
    var size: CGFloat = 24
    var color: Color = Color(hex: 0xC9A84C)

    var body: some View {
        if let _ = UIImage(named: "triskele") {
            Image("triskele")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        } else {
            // Fallback: three-dot arrangement
            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(color)
                        .frame(width: size * 0.25, height: size * 0.25)
                        .offset(
                            x: cos(Double(i) * 2.094) * size * 0.25,
                            y: sin(Double(i) * 2.094) * size * 0.25
                        )
                }
                Circle()
                    .fill(color)
                    .frame(width: size * 0.15, height: size * 0.15)
            }
            .frame(width: size, height: size)
        }
    }
}
