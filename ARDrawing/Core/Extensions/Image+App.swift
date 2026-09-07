//
//  Image+App.swift
//  ARDrawing
//

import SwiftUI

extension Image {
    /// Looks up an image by name in Assets.xcassets.
    /// Named `app:` (rather than a bare `Image(.foo)`) to avoid colliding
    /// with Xcode's auto-generated `ImageResource` asset symbols.
    init(app appImage: AppImage) {
        self.init(appImage.rawValue)
    }
}
