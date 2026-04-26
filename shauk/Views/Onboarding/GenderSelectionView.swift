import SwiftUI

struct GenderSelectionView: View {
    var vm: OnboardingViewModel
    @Environment(\.appTheme) private var theme

    private var c: ThemeColors { theme.colors }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            Text("How do you identify?")
                .font(DesignFonts.playfair(size: 22))
                .foregroundColor(c.t1)
                .padding(.bottom, Spacing.xs)

            Text("We use this to show you the right styles.")
                .font(DesignFonts.dmSans(size: 13, weight: .light))
                .foregroundColor(c.t3)
                .lineSpacing(4)
                .padding(.bottom, Spacing.xxxl)

            HStack(spacing: Spacing.sm) {
                GenderCard(
                    icon: "👗",
                    label: "Woman",
                    isSelected: vm.gender == .female,
                    colors: c
                ) { vm.gender = .female }

                GenderCard(
                    icon: "🧣",
                    label: "Man",
                    isSelected: vm.gender == .male,
                    colors: c
                ) { vm.gender = .male }
            }
            .padding(.bottom, Spacing.xxxl)

            Spacer()

            Button("Continue") { vm.advanceFromGender() }
                .buttonStyle(PrimaryButtonStyle(colors: c, disabled: !vm.canAdvanceFromGender))
                .disabled(!vm.canAdvanceFromGender)
        }
    }
}

// MARK: - Gender Card

private struct GenderCard: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let colors: ThemeColors
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                Text(icon).font(.system(size: 32))
                Text(label)
                    .font(DesignFonts.dmSans(size: 14, weight: .medium))
                    .foregroundColor(colors.t2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .padding(.horizontal, Spacing.md)
            .background(isSelected ? colors.obCardSelected : colors.obCardBg)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.lg)
                    .stroke(isSelected ? colors.accent : colors.border, lineWidth: 1.5)
            )
            .cornerRadius(Radius.lg)
        }
        .buttonStyle(.plain)
        .animation(.shaukSnap, value: isSelected)
    }
}
