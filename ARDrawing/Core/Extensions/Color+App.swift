//
//  Color+App.swift
//  ARDrawing
//

import SwiftUI

extension Color {
    init(app appColor: AppColor) {
        self.init(appColor.rawValue)
    }
}

extension View {
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
