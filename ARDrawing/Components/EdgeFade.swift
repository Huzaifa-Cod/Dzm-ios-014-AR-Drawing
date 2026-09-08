//
//  EdgeFade.swift
//  ARDrawing
//
//  Fades a view out towards all four edges.

import SwiftUI

struct EdgeFade: ViewModifier {
    /// How deep the fade reaches in from each edge, in points.
    /// Zero leaves the view untouched.
    let length: CGFloat

    let size: CGSize

    func body(content: Content) -> some View {
        if length > 0, size.width > 0, size.height > 0 {
            // Masking one gradient with the other multiplies their alpha,
            // which softens the corners as well as the sides.
            content.mask(
                gradient(horizontal: true, extent: size.width)
                    .mask(gradient(horizontal: false, extent: size.height))
            )
        } else {
            content
        }
    }

    private func gradient(horizontal: Bool, extent: CGFloat) -> LinearGradient {
        let fade = min(0.08, length / extent)
        return LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: .white, location: fade),
                .init(color: .white, location: 1 - fade),
                .init(color: .clear, location: 1)
            ],
            startPoint: horizontal ? .leading : .top,
            endPoint: horizontal ? .trailing : .bottom
        )
    }
}

extension View {
    /// Fades this view out towards all four edges. See `EdgeFade`.
    func edgeFade(length: CGFloat, size: CGSize) -> some View {
        modifier(EdgeFade(length: length, size: size))
    }
}
