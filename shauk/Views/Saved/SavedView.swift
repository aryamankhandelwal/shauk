import SwiftUI

// MARK: - SavedView
// Phase 4 stub — empty state until the saved grid is implemented.

struct SavedView: View {
    @Environment(\.appTheme) private var theme

    private var c: ThemeColors { theme.colors }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Your wardrobe")
                    .font(DesignFonts.playfair(size: 22))
                    .foregroundColor(c.t1)
                Spacer()
                Text("0")
                    .font(DesignFonts.dmSans(size: 13))
                    .foregroundColor(c.t4)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(c.bg)
            .overlay(alignment: .bottom) {
                Divider().background(c.border)
            }

            // Empty state
            Spacer()
            VStack(spacing: Spacing.md) {
                Text("✦")
                    .font(.system(size: 36))
                    .foregroundColor(c.t4)
                Text("Nothing saved yet")
                    .font(DesignFonts.playfair(size: 22))
                    .foregroundColor(c.t2)
                Text("Swipe right on looks you love\nand they'll appear here.")
                    .font(DesignFonts.dmSans(size: 14))
                    .foregroundColor(c.t3)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .background(c.bg.ignoresSafeArea())
    }
}

#Preview {
    SavedView()
        .environment(\.appTheme, .light)
}
