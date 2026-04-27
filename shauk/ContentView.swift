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
                MainTabView()
                    .transition(.opacity)
            } else {
                OnboardingContainerView()
                    .transition(.opacity)
            }
        }
        .animation(.shaukFade, value: onboardingComplete)
    }
}

#Preview {
    ContentView()
}
