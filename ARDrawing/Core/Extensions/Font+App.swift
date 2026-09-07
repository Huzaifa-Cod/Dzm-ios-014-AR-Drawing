//
//  Font+App.swift
//  ARDrawing
//

import SwiftUI

extension Font {
    /// Outfit font family, scaled from its Figma point size to the
    /// current device via `ScreenSize`.
    static func app(_ name: AppFontName, size: CGFloat) -> Font {
        .custom(name.rawValue, size: size.s)
    }
}
