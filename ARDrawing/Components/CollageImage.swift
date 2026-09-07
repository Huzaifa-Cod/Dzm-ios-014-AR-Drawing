//
//  CollageImage.swift
//  ARDrawing
//
//  Rounded, cropped photo tile reused across the Intro screen collage.
//

import SwiftUI

struct CollageImage: View {
    let image: AppImage
    var cornerRadius: CGFloat = 20

    var body: some View {
        Image(app: image)
            .resizable()
            .scaledToFill()
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius.s, style: .continuous))
    }
}
