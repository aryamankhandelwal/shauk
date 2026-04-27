import SwiftUI

// MARK: - HomeView

struct HomeView: View {
    @Bindable var vm: HomeViewModel
    @Environment(\.appTheme) private var theme

    private let chips: [(String, ChipColor)] = [
        ("Wedding guest", .weddingGuest),
        ("Sangeet night", .sangeetNight),
        ("Diwali party",  .diwaliParty),
        ("Eid lunch",     .eidLunch),
        ("Reception",     .reception),
    ]

    private var c: ThemeColors { theme.colors }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                header
                greeting
                promptBox
                occasionChips
                if !vm.recentSearches.isEmpty {
                    recentSearches
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.xl)
        }
        .background(c.bg.ignoresSafeArea())
        // Error banner
        .overlay(alignment: .top) {
            if case .error(let msg) = vm.phase {
                errorBanner(msg)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Shauk")
                .font(DesignFonts.playfair(size: 22))
                .foregroundColor(c.t1)
            Spacer()
            avatarCircle(size: 36, fontSize: 15)
        }
    }

    // MARK: - Greeting

    private var greeting: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("What are you")
                .font(DesignFonts.playfair(size: 26))
                .foregroundColor(c.t1)
            Text("dressing up for?")
                .font(DesignFonts.playfair(size: 26, italic: true))
                .foregroundColor(c.accent)
            Text("Describe your occasion — we'll find the looks.")
                .font(DesignFonts.dmSans(size: 13))
                .foregroundColor(c.t3)
                .padding(.top, 4)
        }
    }

    // MARK: - Prompt Box

    private var promptBox: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("DESCRIBE YOUR OCCASION")
                .font(DesignFonts.dmSans(size: 10))
                .foregroundColor(c.t4)
                .tracking(1.2)

            ZStack(alignment: .bottomTrailing) {
                // TextEditor with placeholder overlay
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $vm.prompt)
                        .frame(height: 64)
                        .foregroundColor(c.inputText)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .font(DesignFonts.dmSans(size: 14))

                    if vm.prompt.isEmpty {
                        Text("A wedding in Jaipur, Diwali with family…")
                            .font(DesignFonts.dmSans(size: 14))
                            .foregroundColor(c.placeholder)
                            .allowsHitTesting(false)
                            .padding(.top, 8)
                            .padding(.leading, 4)
                    }
                }

                // Send button
                Button {
                    Task { await vm.search() }
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "0a0907"))
                        .frame(width: 38, height: 38)
                        .background(c.accent)
                        .cornerRadius(Radius.sm)
                }
                .opacity(vm.canSearch ? 1.0 : 0.3)
                .disabled(!vm.canSearch)
            }
        }
        .padding(Spacing.md)
        .background(c.surface)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.xl)
                .stroke(c.border, lineWidth: 1.5)
        )
        .cornerRadius(Radius.xl)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Occasion Chips

    private var occasionChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.xs) {
                ForEach(chips, id: \.0) { label, chipColor in
                    chipView(label: label, color: chipColor)
                }
            }
            .padding(.horizontal, 1)
        }
    }

    private func chipView(label: String, color: ChipColor) -> some View {
        let isDark = theme == .dark
        let bg     = isDark ? c.chipBg     : color.bg
        let border = isDark ? c.chipBorder : color.border
        let text   = isDark ? c.chipText   : color.text

        return Button {
            Task { await vm.searchChip(label) }
        } label: {
            Text(label)
                .font(DesignFonts.dmSans(size: 13, weight: .medium))
                .foregroundColor(text)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xxs + 2)
                .background(bg)
                .overlay(
                    Capsule().stroke(border, lineWidth: 1)
                )
                .clipShape(Capsule())
        }
    }

    // MARK: - Recent Searches

    private var recentSearches: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("RECENT SEARCHES")
                .font(DesignFonts.dmSans(size: 10))
                .foregroundColor(c.t4)
                .tracking(1.2)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(vm.recentSearches.prefix(5), id: \.self) { query in
                        recentSearchCard(query: query)
                    }
                }
                .padding(.horizontal, 1)
            }
        }
    }

    private func recentSearchCard(query: String) -> some View {
        Button {
            vm.prompt = query
            Task { await vm.search() }
        } label: {
            ZStack(alignment: .bottomLeading) {
                LinearGradient(
                    colors: [Color(hex: "1a1510"), Color(hex: "0a0804")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Text(query)
                    .font(DesignFonts.dmSans(size: 10, weight: .medium))
                    .foregroundColor(Color(hex: "c9a96e"))
                    .lineLimit(2)
                    .padding(Spacing.xs)
            }
            .frame(width: 80, height: 106)
            .cornerRadius(Radius.md)
        }
    }

    // MARK: - Avatar

    private func avatarCircle(size: CGFloat, fontSize: CGFloat) -> some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "c9a96e"), Color(hex: "7a4f2a")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Text("S")
                .font(DesignFonts.playfair(size: fontSize, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    // MARK: - Error Banner

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 13))
            Text(message)
                .font(DesignFonts.dmSans(size: 12))
            Spacer()
            Button { vm.reset() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Color(hex: "d45858"))
        .padding(.horizontal, Spacing.md)
        .padding(.top, 8)
    }
}

#Preview {
    @Previewable @State var vm = HomeViewModel()
    HomeView(vm: vm)
        .environment(\.appTheme, .light)
}
