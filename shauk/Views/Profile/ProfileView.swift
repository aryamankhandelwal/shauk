import SwiftUI

// MARK: - ProfileView

struct ProfileView: View {
    @Environment(\.appTheme) private var theme
    @AppStorage("theme") private var themeRaw: String = AppTheme.light.rawValue

    // User data from UserDefaults (written during onboarding)
    @AppStorage("onboardingGender")     private var genderRaw: String = ""
    @AppStorage("onboardingTopSize")    private var topSizeRaw: String = ""
    @AppStorage("onboardingBottomSize") private var bottomSizeRaw: String = ""

    private var c: ThemeColors { theme.colors }
    private var isDark: Bool { themeRaw == AppTheme.dark.rawValue }

    private var profileDetail: String {
        var parts: [String] = []
        if !genderRaw.isEmpty {
            parts.append(genderRaw.capitalized)
        }
        if !topSizeRaw.isEmpty {
            parts.append("Top \(topSizeRaw)")
        }
        if !bottomSizeRaw.isEmpty {
            parts.append("Bottom \(bottomSizeRaw)")
        }
        return parts.joined(separator: " · ")
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Header avatar
                VStack(spacing: Spacing.sm) {
                    avatarCircle
                    Text("Shauk Member")
                        .font(DesignFonts.playfair(size: 20))
                        .foregroundColor(c.t1)
                    if !profileDetail.isEmpty {
                        Text(profileDetail)
                            .font(DesignFonts.dmSans(size: 13))
                            .foregroundColor(c.t3)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.xxxl)

                // Sections
                VStack(spacing: Spacing.md) {
                    appearanceSection
                    sizesSection
                    activitySection
                    accountSection
                }
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.xxxl)
            }
        }
        .background(c.bg.ignoresSafeArea())
    }

    // MARK: - Avatar

    private var avatarCircle: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "c9a96e"), Color(hex: "7a4f2a")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Text("S")
                .font(DesignFonts.playfair(size: 26, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(width: 72, height: 72)
        .clipShape(Circle())
    }

    // MARK: - Appearance Section

    private var appearanceSection: some View {
        profileSection(title: "APPEARANCE") {
            HStack {
                Text("Theme")
                    .font(DesignFonts.dmSans(size: 15))
                    .foregroundColor(c.t1)
                Spacer()
                themeToggle
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
        }
    }

    private var themeToggle: some View {
        HStack(spacing: 0) {
            themeOption(label: "🌙 Dark", selected: isDark) {
                themeRaw = AppTheme.dark.rawValue
            }
            themeOption(label: "☀️ Light", selected: !isDark) {
                themeRaw = AppTheme.light.rawValue
            }
        }
        .background(c.surface)
        .overlay(
            Capsule().stroke(c.border, lineWidth: 1)
        )
        .clipShape(Capsule())
    }

    private func themeOption(label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(DesignFonts.dmSans(size: 12, weight: selected ? .semibold : .regular))
                .foregroundColor(selected ? Color(hex: "0a0907") : c.t3)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, 7)
                .background(selected ? c.accent : Color.clear)
                .clipShape(Capsule())
        }
    }

    // MARK: - Sizes Section

    private var sizesSection: some View {
        profileSection(title: "YOUR SIZES") {
            VStack(spacing: 0) {
                sizeRow(label: "Top size", value: topSizeRaw.isEmpty ? "Not set" : topSizeRaw)
                Divider().padding(.horizontal, Spacing.md).background(c.border)
                sizeRow(label: "Bottom size", value: bottomSizeRaw.isEmpty ? "Not set" : bottomSizeRaw)
            }
        }
    }

    private func sizeRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(DesignFonts.dmSans(size: 15))
                .foregroundColor(c.t1)
            Spacer()
            Text(value)
                .font(DesignFonts.dmSans(size: 15))
                .foregroundColor(c.t3)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Activity Section

    private var activitySection: some View {
        profileSection(title: "ACTIVITY") {
            VStack(spacing: 0) {
                stubRow(label: "Items saved", value: "0")
                Divider().padding(.horizontal, Spacing.md).background(c.border)
                stubRow(label: "Searches", value: "\(UserDefaults.standard.stringArray(forKey: "recentSearches")?.count ?? 0)")
            }
        }
    }

    private func stubRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(DesignFonts.dmSans(size: 15))
                .foregroundColor(c.t1)
            Spacer()
            Text(value)
                .font(DesignFonts.dmSans(size: 15))
                .foregroundColor(c.t3)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Account Section

    private var accountSection: some View {
        profileSection(title: "ACCOUNT") {
            VStack(spacing: 0) {
                accountRow(label: "Notifications")
                Divider().padding(.horizontal, Spacing.md).background(c.border)
                accountRow(label: "Privacy")
                Divider().padding(.horizontal, Spacing.md).background(c.border)
                accountRow(label: "Sign out", destructive: true)
            }
        }
    }

    private func accountRow(label: String, destructive: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(DesignFonts.dmSans(size: 15))
                .foregroundColor(destructive ? Color(hex: "d45858") : c.t1)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(c.t4)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .contentShape(Rectangle())
        .onTapGesture {}
    }

    // MARK: - Section Helper

    private func profileSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(DesignFonts.dmSans(size: 10))
                .foregroundColor(c.t4)
                .tracking(1.2)
                .padding(.horizontal, Spacing.xxs)

            VStack(spacing: 0) {
                content()
            }
            .background(c.surface)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md)
                    .stroke(c.border, lineWidth: 1)
            )
            .cornerRadius(Radius.md)
        }
    }
}

#Preview {
    ProfileView()
        .environment(\.appTheme, .light)
}
