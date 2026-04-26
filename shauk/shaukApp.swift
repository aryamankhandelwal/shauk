//
//  shaukApp.swift
//  shauk
//
//  Created by Aryaman on 4/26/26.
//

import SwiftUI
import CoreText

@main
struct shaukApp: App {
    @AppStorage("theme") private var themeRaw: String = AppTheme.light.rawValue

    init() {
        let fonts = [
            "PlayfairDisplay-Regular", "PlayfairDisplay-Medium",
            "PlayfairDisplay-SemiBold", "PlayfairDisplay-Bold",
            "PlayfairDisplay-Italic", "DMSans-Light", "DMSans-Regular",
            "DMSans-Medium", "DMSans-SemiBold", "DMSans-Bold"
        ]
        for name in fonts {
            if let url = Bundle.main.url(forResource: name, withExtension: "ttf") {
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.appTheme, AppTheme(rawValue: themeRaw) ?? .light)
                // Force light system appearance; the app manages its own theming
                .preferredColorScheme(.light)
        }
    }
}
