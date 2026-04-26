import SwiftUI

struct MeasurementPromptView: View {
    var vm: OnboardingViewModel
    @Environment(\.appTheme) private var theme

    private var c: ThemeColors { theme.colors }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            Text("Want to add more detail for better fits?")
                .font(DesignFonts.playfair(size: 22))
                .foregroundColor(c.t1)
                .lineSpacing(4)
                .padding(.bottom, Spacing.xs)

            Text("Your exact measurements help us surface outfits in the right size. Takes 30 seconds.")
                .font(DesignFonts.dmSans(size: 13, weight: .light))
                .foregroundColor(c.t3)
                .lineSpacing(4)
                .padding(.bottom, Spacing.xxxl)

            Spacer()

            // Continue → measurements screen
            Button("Continue") { vm.advanceToMeasurements() }
                .buttonStyle(PrimaryButtonStyle(colors: c))

            // Skip → complete onboarding without measurements
            AsyncGhostButton(label: "Skip for now", colors: c, isLoading: vm.isSaving) {
                await vm.skipAndComplete()
            }
            .padding(.top, Spacing.xs)
        }
        .alert("Couldn't save profile", isPresented: .init(
            get: { vm.saveError != nil },
            set: { if !$0 { vm.dismissError() } }
        )) {
            Button("Retry") { Task { await vm.skipAndComplete() } }
            Button("Cancel", role: .cancel) { vm.dismissError() }
        } message: {
            Text(vm.saveError ?? "")
        }
    }
}

// MARK: - Async Ghost Button

/// Ghost button that can show a loading spinner for async actions.
struct AsyncGhostButton: View {
    let label: String
    let colors: ThemeColors
    let isLoading: Bool
    let action: () async -> Void

    var body: some View {
        Button {
            Task { await action() }
        } label: {
            if isLoading {
                ProgressView()
                    .tint(colors.t3)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            } else {
                Text(label)
                    .font(DesignFonts.dmSans(size: 14))
                    .foregroundColor(colors.t3)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}
