import SwiftUI

struct LevelMapView: View {
    @ObservedObject var viewModel: LevelMapViewModel
    var onSelectLevel: (Int) -> Void
    var onBack: () -> Void

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: 0x2D1B12), Color(hex: 0x1A0F0A), Color(hex: 0x0D0705)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.bold))
                            .foregroundColor(Color(hex: 0xCCBB99))
                            .padding(12)
                    }

                    Spacer()

                    Text("Mine Shaft")
                        .font(.title2.weight(.bold))
                        .foregroundColor(Color(hex: 0xFFD700))

                    Spacer()

                    // Invisible spacer for centering
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal)

                // Scrollable level map
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.levels.reversed()) { level in
                                LevelNodeView(item: level)
                                    .id(level.number)
                                    .onTapGesture {
                                        if level.isUnlocked {
                                            onSelectLevel(level.number)
                                        }
                                    }
                            }
                        }
                        .padding(.vertical, 20)
                    }
                    .onAppear {
                        withAnimation {
                            proxy.scrollTo(viewModel.currentLevel, anchor: .center)
                        }
                    }
                }
            }
        }
    }
}

struct LevelNodeView: View {
    let item: LevelMapItem

    var body: some View {
        HStack {
            // Alternating left/right positioning for snake path
            if item.number % 2 == 0 {
                Spacer()
            }

            VStack(spacing: 4) {
                // Level circle
                ZStack {
                    Circle()
                        .fill(item.isUnlocked ?
                              LinearGradient(colors: [Color(hex: 0xE8A035), Color(hex: 0xC68020)],
                                             startPoint: .top, endPoint: .bottom) :
                              LinearGradient(colors: [Color(hex: 0x3D2B1F), Color(hex: 0x2D1B12)],
                                             startPoint: .top, endPoint: .bottom))
                        .frame(width: 56, height: 56)
                        .shadow(color: item.isUnlocked ? Color(hex: 0xE8A035).opacity(0.3) : .clear,
                                radius: 5)

                    if item.isUnlocked {
                        Text("\(item.number)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: 0x6B4F3A))
                    }
                }

                // Stars
                if item.stars > 0 {
                    StarRatingView(stars: item.stars, size: 12)
                }
            }
            .padding(.vertical, 8)

            if item.number % 2 != 0 {
                Spacer()
            }
        }
        .padding(.horizontal, 60)

        // Connecting line
        Rectangle()
            .fill(Color(hex: 0x6B4F3A).opacity(0.3))
            .frame(width: 2, height: 20)
    }
}
