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
