import SwiftUI

// MARK: - LoadingView

struct LoadingView: View {
    let query: String
    @Environment(\.appTheme) private var theme

    private let steps = [
        "Parsing your occasion…",
        "Searching Indian fashion sites…",
        "Screenshotting product pages…",
        "Curating your feed…",
    ]

    @State private var stepIndex = 0
    @State private var pulse = false

    private var c: ThemeColors { theme.colors }

    var body: some View {
        ZStack {
            c.bg.ignoresSafeArea()

            VStack(spacing: Spacing.xxxl) {
                // Brand
                Text("Shauk")
                    .font(DesignFonts.playfair(size: 32))
                    .foregroundColor(c.accent)

                VStack(spacing: Spacing.xl) {
                    // Step text — animates every 700ms
                    Text(steps[stepIndex])
                        .font(DesignFonts.dmSans(size: 14))
                        .foregroundColor(c.t2)
                        .id(stepIndex) // forces re-render + transition
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.25), value: stepIndex)

                    // Pulsing dots
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .fill(c.accent)
                                .frame(width: 5, height: 5)
                                .opacity(pulse ? 0.2 : 1.0)
                                .animation(
                                    .easeInOut(duration: 0.4)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(i) * 0.2),
                                    value: pulse
                                )
                        }
                    }
                }

                // Query card
                Text("\"\(query)\"")
                    .font(DesignFonts.playfair(size: 13, italic: true))
                    .foregroundColor(c.t3)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .background(c.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.sm)
                            .stroke(c.border, lineWidth: 1)
                    )
                    .cornerRadius(Radius.sm)
                    .padding(.horizontal, Spacing.xxxl)
            }
            .padding(Spacing.xl)
        }
        .onAppear {
            pulse = true
        }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 700_000_000)
                withAnimation {
                    stepIndex = (stepIndex + 1) % steps.count
                }
            }
        }
    }
}

#Preview {
    LoadingView(query: "Cousin's wedding in Mumbai")
        .environment(\.appTheme, .light)
}
