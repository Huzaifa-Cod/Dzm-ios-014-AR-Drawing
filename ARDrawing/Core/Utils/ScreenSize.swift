//
//  ScreenSize.swift
//  ARDrawing
//
//  Scales Figma pixel values to any device so layouts stay
//  pixel-perfect on the design frame (iPhone 15 / 393x852) and
//  proportionally correct on every other screen size.
//

import SwiftUI

enum ScreenSize {
    /// Figma design frame size. Every exported artwork is 390pt wide,
    /// so the design frame is an iPhone 14 (390x844).
    static let designWidth: CGFloat = 390
    static let designHeight: CGFloat = 844

    static var current: CGSize {
        UIScreen.main.bounds.size
    }

    static var widthScale: CGFloat {
        current.width / designWidth
    }

    static var heightScale: CGFloat {
        current.height / designHeight
    }

    /// Uses the smaller of the two scales so nothing overflows on
    /// unusually narrow or short devices.
    static var minScale: CGFloat {
        min(widthScale, heightScale)
    }
}

extension CGFloat {
    /// Scales a Figma horizontal value to the current device width.
    var w: CGFloat { self * ScreenSize.widthScale }
    /// Scales a Figma vertical value to the current device height.
    var h: CGFloat { self * ScreenSize.heightScale }
    /// Scales a Figma value (fonts, radii, icons) uniformly.
    var s: CGFloat { self * ScreenSize.minScale }
}

extension Int {
    var w: CGFloat { CGFloat(self).w }
    var h: CGFloat { CGFloat(self).h }
    var s: CGFloat { CGFloat(self).s }
}
