//
//  ScreenSize.swift
//  ARDrawing
//
//  Scales Figma values to the current device.
//
//  The design is a phone layout drawn on a 390x844 frame. Everything in the
//  app — fonts, paddings, card sizes, corner radii — is written in those
//  design points and scaled through `.w` / `.h` / `.s`.
//
//  The scale is a single uniform factor: how much of the design frame fits
//  on this screen, i.e. an aspect fit. That matters on tablets. Scaling each
//  axis independently would stretch a 13" iPad's width by 2.6 and its height
//  by 1.6, shearing the design against its own vertical rhythm; fitting it
//  as a whole enlarges every element the way a photo enlarges, so a tablet
//  gets bigger text, cards and controls rather than a phone-sized layout
//  adrift in the middle of the glass.
//
//  Screens still lay their content out edge to edge (no centred-column
//  cap) — a grid like Templates' should add columns on a wider screen
//  rather than sit at its phone column count with extra margin either
//  side. See `TemplatesView.columnCount` for that.
//

import SwiftUI

enum ScreenSize {
    /// Figma design frame (iPhone 14).
    static let designWidth: CGFloat = 390
    static let designHeight: CGFloat = 844

    /// Scale bounds. The floor stops small phones shrinking body copy below
    /// legibility; the ceiling is a backstop for very large displays.
    private static let minimumScale: CGFloat = 0.88
    private static let maximumScale: CGFloat = 1.8

    /// The one scale everything is drawn at.
    ///
    /// Roughly 0.88 on an iPhone SE, 1.0 on the design device, and 1.4–1.6
    /// on iPads — a tablet gets a genuinely larger layout, not a phone-sized
    /// one.
    static var scale: CGFloat {
        let screen = UIScreen.main.bounds.size
        guard screen.width > 0, screen.height > 0 else { return 1 }
        let fit = min(screen.width / designWidth, screen.height / designHeight)
        return min(max(fit, minimumScale), maximumScale)
    }

    /// The current screen's width in points. Screens that add columns or
    /// otherwise reflow on a wider device (see `TemplatesView`) read this
    /// directly rather than through the design-frame scale above.
    static var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }

    // Kept as separate names so call sites can still say what a value means
    // — horizontal, vertical, or uniform — even though one scale backs them.
    static var widthScale: CGFloat { scale }
    static var heightScale: CGFloat { scale }
    static var minScale: CGFloat { scale }
}

extension CGFloat {
    /// Scales a Figma horizontal value to the current device.
    var w: CGFloat { self * ScreenSize.widthScale }
    /// Scales a Figma vertical value to the current device.
    var h: CGFloat { self * ScreenSize.heightScale }
    /// Scales a Figma value (fonts, radii, icons) to the current device.
    var s: CGFloat { self * ScreenSize.minScale }
}

extension Int {
    var w: CGFloat { CGFloat(self).w }
    var h: CGFloat { CGFloat(self).h }
    var s: CGFloat { CGFloat(self).s }
}
