//
//  Image+App.swift
//  ARDrawing
//

import SwiftUI

extension Image {
    init(app appImage: AppImage) {
        self.init(appImage.rawValue)
    }
}
