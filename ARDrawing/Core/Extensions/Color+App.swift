//
//  Color+App.swift
//  ARDrawing
//

import SwiftUI

extension Color {
    /// Looks up a color by name in Assets.xcassets.
    /// Named `app:` (rather than a bare `Color(.foo)`) to avoid colliding
    /// with Xcode's auto-generated `ColorResource` asset symbols.
    init(app appColor: AppColor) {
        self.init(appColor.rawValue)
    }
}

extension View {
    /// Vertical white → off-white wash used behind screens that sit under
    /// a rounded white header (e.g. Album, Draw Mode) — white FFFFFF at
    /// the top fading to F7F8FA by the bottom of the screen.
    func screenGradientBackground() -> some View {
        background(
            LinearGradient(
                colors: [Color(app: .white), Color(app: .gradientEnd)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}
