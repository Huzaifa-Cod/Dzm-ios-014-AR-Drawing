//
//  Color+App.swift
//  ARDrawing
//

import SwiftUI

extension Color {
    /// Looks up a color by name in Assets.xcassets/Colors.
    init(_ appColor: AppColor) {
        self.init(appColor.rawValue)
    }
}
