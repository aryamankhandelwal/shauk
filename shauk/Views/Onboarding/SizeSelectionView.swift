import SwiftUI

struct SizeSelectionView: View {
    var vm: OnboardingViewModel
    @Environment(\.appTheme) private var theme

    private var c: ThemeColors { theme.colors }
    private let sizes = ClothingSize.allCases

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            Text("What are your sizes?")
                .font(DesignFonts.playfair(size: 22))
                .foregroundColor(c.t1)
                .padding(.bottom, Spacing.xs)

            Text("We'll use these to surface the right fits.")
                .font(DesignFonts.dmSans(size: 13, weight: .light))
                .foregroundColor(c.t3)
                .lineSpacing(4)
                .padding(.bottom, Spacing.xxl)

            // Top sizes
            SectionLabel(text: "Top — kurtas, blouses, jackets", colors: c)
            SizePillRow(selected: vm.topSize, colors: c) { vm.topSize = $0 }
                .padding(.bottom, Spacing.lg)

            // Bottom sizes
            SectionLabel(text: "Bottom — lehengas, salwars, skirts", colors: c)
            SizePillRow(selected: vm.bottomSize, colors: c) { vm.bottomSize = $0 }
                .padding(.bottom, Spacing.xxxl)

            Spacer()

            Button("Continue") { vm.advanceFromSizes() }
                .buttonStyle(PrimaryButtonStyle(colors: c, disabled: !vm.canAdvanceFromSizes))
                .disabled(!vm.canAdvanceFromSizes)
        }
    }
}

// MARK: - Section Label

private struct SectionLabel: View {
    let text: String
    let colors: ThemeColors

    var body: some View {
        Text(text.uppercased())
            .font(DesignFonts.dmSans(size: 12))
            .foregroundColor(colors.t3)
            .kerning(1.0)
            .padding(.bottom, Spacing.xs)
    }
}

// MARK: - Size Pill Row

private struct SizePillRow: View {
    let selected: ClothingSize?
    let colors: ThemeColors
    let onSelect: (ClothingSize) -> Void

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(ClothingSize.allCases, id: \.self) { size in
                SizePill(size: size, isSelected: selected == size, colors: colors) {
                    onSelect(size)
                }
            }
        }
    }
}

// MARK: - Size Pill

private struct SizePill: View {
    let size: ClothingSize
    let isSelected: Bool
    let colors: ThemeColors
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(size.rawValue)
                .font(DesignFonts.dmSans(size: 13, weight: .medium))
                .foregroundColor(isSelected ? colors.t1 : colors.t2)
                .frame(width: 52, height: 52)
                .background(isSelected ? colors.obCardSelected : colors.obCardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(isSelected ? colors.accent : colors.border, lineWidth: 1.5)
                )
                .cornerRadius(Radius.md)
        }
        .buttonStyle(.plain)
        .animation(.shaukSnap, value: isSelected)
    }
}
