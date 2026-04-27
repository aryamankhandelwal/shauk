import SwiftUI

// MARK: - SwipeFeedView
// Phase 3: Full-screen vertical swipe feed (TikTok-style)

struct SwipeFeedView: View {
    let cards: [OutfitCard]
    let onBack: () -> Void

    @State private var currentIndex: Int = 0
    @State private var likedIDs: Set<String> = []

    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: "060504").ignoresSafeArea()

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                TabView(selection: $currentIndex) {
                    ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                        FeedCardView(
                            card: card,
                            size: geo.size,
                            isLiked: likedIDs.contains(card.id),
                            onLike: { toggleLike(card.id) }
                        )
                        .tag(index)
                        .rotationEffect(.degrees(-90))
                        .frame(width: w, height: h)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                // Rotate the container to make the pager scroll vertically
                .frame(width: h, height: w)
                .rotationEffect(.degrees(90), anchor: .topLeading)
                .offset(x: w)
            }
            .ignoresSafeArea()

            topBar
        }
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button(action: onBack) {
                HStack(spacing: 5) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Back")
                        .font(DesignFonts.dmSans(size: 14))
                }
                .foregroundColor(Color(hex: "f0e6d3"))
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, 7)
                .background(Color.black.opacity(0.5))
                .cornerRadius(Radius.pill)
            }

            Spacer()

            Text("\(currentIndex + 1) of \(cards.count)")
                .font(DesignFonts.dmSans(size: 12))
                .foregroundColor(Color(hex: "8a7a6a"))
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, 7)
                .background(Color.black.opacity(0.5))
                .cornerRadius(Radius.pill)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, 56)
    }

    private func toggleLike(_ id: String) {
        if likedIDs.contains(id) {
            likedIDs.remove(id)
        } else {
            likedIDs.insert(id)
        }
    }
}

// MARK: - FeedCardView

private struct FeedCardView: View {
    let card: OutfitCard
    let size: CGSize
    let isLiked: Bool
    let onLike: () -> Void

    @State private var heartScale: CGFloat = 1.0

    var body: some View {
        ZStack(alignment: .bottom) {
            cardImage
            bottomOverlay
            sideActions
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, Spacing.md)
                .padding(.bottom, 120)
        }
        .frame(width: size.width, height: size.height)
        .background(Color(hex: "060504"))
        .clipped()
    }

    // MARK: Image

    @ViewBuilder
    private var cardImage: some View {
        if let imageBase64 = card.imageBase64,
           let data = Data(base64Encoded: imageBase64),
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height)
                .clipped()
        } else {
            ZStack {
                Color(hex: "0d0b09")
                VStack(spacing: Spacing.md) {
                    ProgressView()
                        .tint(Color(hex: "c9a96e"))
                        .scaleEffect(1.4)
                    Text("Loading look…")
                        .font(DesignFonts.dmSans(size: 13))
                        .foregroundColor(Color(hex: "5a4e42"))
                }
            }
            .frame(width: size.width, height: size.height)
        }
    }

    // MARK: Bottom overlay

    private var bottomOverlay: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(card.brand.uppercased())
                .font(DesignFonts.dmSans(size: 10, weight: .semibold))
                .foregroundColor(Color(hex: "c9a96e"))
                .tracking(1.5)

            Text(card.name)
                .font(DesignFonts.playfair(size: 26))
                .foregroundColor(Color(hex: "f0e6d3"))
                .lineLimit(2)

            if let price = card.price {
                Text(price)
                    .font(DesignFonts.dmSans(size: 14))
                    .foregroundColor(Color(hex: "8a7a6a"))
            }

            if !card.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.xxs) {
                        ForEach(card.tags, id: \.self) { tag in
                            Text(tag)
                                .font(DesignFonts.dmSans(size: 11))
                                .foregroundColor(Color(hex: "c9a96e"))
                                .padding(.horizontal, Spacing.xs)
                                .padding(.vertical, 3)
                                .background(Color(hex: "c9a96e").opacity(0.12))
                                .overlay(Capsule().stroke(Color(hex: "c9a96e").opacity(0.22), lineWidth: 1))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.xxxl)
        .padding(.bottom, 52)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [.clear, Color.black.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    // MARK: Side actions

    private var sideActions: some View {
        VStack(spacing: Spacing.xl) {
            // Like
            Button(action: {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.45)) {
                    heartScale = 1.5
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        heartScale = 1.0
                    }
                }
                onLike()
            }) {
                VStack(spacing: 4) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundColor(isLiked ? Color(hex: "e05a7a") : Color(hex: "f0e6d3"))
                        .scaleEffect(heartScale)
                        .shadow(color: isLiked ? Color(hex: "e05a7a").opacity(0.5) : .clear, radius: 8)
                    Text(isLiked ? "Liked" : "Like")
                        .font(DesignFonts.dmSans(size: 11))
                        .foregroundColor(Color(hex: "8a7a6a"))
                }
            }
            .animation(.spring(response: 0.3), value: isLiked)

            // Shop
            Button(action: {
                if let url = URL(string: card.sourceURL) {
                    UIApplication.shared.open(url)
                }
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "bag")
                        .font(.system(size: 26, weight: .medium))
                        .foregroundColor(Color(hex: "f0e6d3"))
                    Text("Shop")
                        .font(DesignFonts.dmSans(size: 11))
                        .foregroundColor(Color(hex: "8a7a6a"))
                }
            }
        }
    }
}

#Preview {
    SwipeFeedView(cards: [], onBack: {})
}
