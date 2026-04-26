import SwiftUI

struct OnboardingContainerView: View {
    @State private var vm = OnboardingViewModel()
    @Environment(\.appTheme) private var theme
    @AppStorage("onboardingComplete") private var onboardingComplete = false

    private var c: ThemeColors { theme.colors }

    var body: some View {
        ZStack {
            c.bg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Header (logo + tagline + progress dots)
                header
                    .padding(.horizontal, Spacing.xxl)
                    .padding(.top, Spacing.lg)

                // Step content
                stepContent
                    .padding(.horizontal, Spacing.xxl)
                    .padding(.bottom, Spacing.xxl)
            }
        }
        .preferredColorScheme(.light) // Lock to light for onboarding background; theme tokens handle colour
        .onChange(of: onboardingComplete) { _, _ in }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Shauk")
                .font(DesignFonts.playfair(size: 28))
                .foregroundColor(c.t1)
                .padding(.bottom, 6)

            Text("Occasion wear for the diaspora".uppercased())
                .font(DesignFonts.dmSans(size: 12, weight: .light))
                .foregroundColor(c.t3)
                .kerning(1.2)
                .padding(.bottom, Spacing.xxl)

            // Progress dots — 3 steps (gender, sizes, measurements)
            ProgressDots(
                total: 3,
                current: min(vm.step.rawValue, 2),
                accentColor: c.accent,
                baseColor: c.border
            )
            .padding(.bottom, Spacing.xxxl)
        }
    }

    // MARK: - Step Content

    @ViewBuilder
    private var stepContent: some View {
        switch vm.step {
        case .gender:
            GenderSelectionView(vm: vm)
                .transition(.shaukSlideUp)
                .id("gender")

        case .sizes:
            SizeSelectionView(vm: vm)
                .transition(.shaukSlideUp)
                .id("sizes")

        case .measurementPrompt:
            MeasurementPromptView(vm: vm)
                .transition(.shaukSlideUp)
                .id("measurementPrompt")

        case .measurements:
            MeasurementsView(vm: vm)
                .transition(.shaukSlideUp)
                .id("measurements")
        }
    }
}

// MARK: - Progress Dots

private struct ProgressDots: View {
    let total: Int
    let current: Int
    let accentColor: Color
    let baseColor: Color

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index <= current ? accentColor : baseColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 3)
                    .animation(.shaukSnap, value: current)
            }
        }
    }
}
