import SwiftUI

// MARK: - ResultsListView
// Phase 2 placeholder — Phase 3 replaces this with the swipe card feed.

struct ResultsListView: View {
    let cards: [OutfitCard]
    let onBack: () -> Void
    @Environment(\.appTheme) private var theme

    private var c: ThemeColors { theme.colors }

    var body: some View {
        VStack(spacing: 0) {
            // Navigation bar
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back")
                            .font(DesignFonts.dmSans(size: 15))
                    }
                    .foregroundColor(c.accent)
                }
                Spacer()
                Text("\(cards.count) look\(cards.count == 1 ? "" : "s")")
                    .font(DesignFonts.dmSans(size: 13))
                    .foregroundColor(c.t3)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(c.bg)
            .overlay(alignment: .bottom) {
                Divider().background(c.border)
            }

            if cards.isEmpty {
                emptyState
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: Spacing.md) {
                        ForEach(cards) { card in
                            OutfitCardRow(card: card, theme: theme)
                        }
                    }
                    .padding(Spacing.md)
                }
            }
        }
        .background(c.bg.ignoresSafeArea())
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            Spacer()
            Text("✦")
                .font(.system(size: 32))
                .foregroundColor(c.t4)
            Text("No looks found")
                .font(DesignFonts.playfair(size: 20))
                .foregroundColor(c.t2)
            Text("Try a different occasion description")
                .font(DesignFonts.dmSans(size: 14))
                .foregroundColor(c.t3)
            Spacer()
        }
    }
}

// MARK: - OutfitCardRow

private struct OutfitCardRow: View {
    let card: OutfitCard
    let theme: AppTheme

    private var c: ThemeColors { theme.colors }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image
            cardImage

            // Info
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(card.brand.uppercased())
                    .font(DesignFonts.dmSans(size: 10, weight: .semibold))
                    .foregroundColor(c.accent)
                    .tracking(1.2)

                Text(card.name)
                    .font(DesignFonts.playfair(size: 20))
                    .foregroundColor(c.t1)

                HStack(spacing: Spacing.xs) {
                    if let price = card.price {
                        Text(price)
                            .font(DesignFonts.dmSans(size: 13))
                            .foregroundColor(c.t2)
                    }
                    if let occasion = card.occasion {
                        Text("·")
                            .foregroundColor(c.t4)
                        Text(occasion)
                            .font(DesignFonts.dmSans(size: 13))
                            .foregroundColor(c.t3)
                    }
                }

                if !card.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.xxs) {
                            ForEach(card.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(DesignFonts.dmSans(size: 11))
                                    .foregroundColor(c.accent)
                                    .padding(.horizontal, Spacing.xs)
                                    .padding(.vertical, 3)
                                    .background(c.accentBg)
                                    .overlay(
                                        Capsule()
                                            .stroke(c.accentBorder, lineWidth: 1)
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            .padding(Spacing.md)
        }
        .background(c.card)
        .cornerRadius(Radius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg)
                .stroke(c.border, lineWidth: 1)
        )
    }

    @ViewBuilder
    private var cardImage: some View {
        if let imageBase64 = card.imageBase64,
           let data = Data(base64Encoded: imageBase64),
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 280)
                .clipped()
        } else {
            // Fallback gradient placeholder
            LinearGradient(
                colors: [Color(hex: "1a1510"), Color(hex: "0d0b09")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(maxWidth: .infinity)
            .frame(height: 280)
        }
    }
}

#Preview {
    ResultsListView(cards: [], onBack: {})
        .environment(\.appTheme, .light)
}
