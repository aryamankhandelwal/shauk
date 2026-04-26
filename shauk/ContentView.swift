//
//  ContentView.swift
//  shauk
//
//  Created by Aryaman on 4/26/26.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("onboardingComplete") private var onboardingComplete = false
    @AppStorage("theme") private var themeRaw: String = AppTheme.light.rawValue
    @Environment(\.appTheme) private var theme

    var body: some View {
        Group {
            if onboardingComplete {
                HomeStubView()
                    .transition(.opacity)
            } else {
                OnboardingContainerView()
                    .transition(.opacity)
            }
        }
        .animation(.shaukFade, value: onboardingComplete)
    }
}

// MARK: - Home Stub (Phase 2 will replace this)

private struct HomeStubView: View {
    @Environment(\.appTheme) private var theme
    @AppStorage("onboardingComplete") private var onboardingComplete = false

    private var c: ThemeColors { theme.colors }

    var body: some View {
        ZStack {
            c.bg.ignoresSafeArea()

            VStack(spacing: Spacing.md) {
                Text("Shauk")
                    .font(DesignFonts.playfair(size: 32))
                    .foregroundColor(c.t1)

                Text("Home screen coming in Phase 2")
                    .font(DesignFonts.dmSans(size: 14))
                    .foregroundColor(c.t3)

                // Dev-only reset button
                Button("Reset onboarding") {
                    UserDefaults.standard.removeObject(forKey: "onboardingComplete")
                    UserDefaults.standard.removeObject(forKey: "onboardingStep")
                    onboardingComplete = false
                }
                .font(DesignFonts.dmSans(size: 12))
                .foregroundColor(c.t4)
                .padding(.top, Spacing.xl)
            }
        }
    }
}

#Preview {
    ContentView()
}
