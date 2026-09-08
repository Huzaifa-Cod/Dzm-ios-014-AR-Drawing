//
//  TabPlaceholderView.swift
//  ARDrawing
//

import SwiftUI

struct TabPlaceholderView: View {
    let tab: AppTab

    var body: some View {
        VStack(spacing: 16.h) {
            Image(app: tab.activeImage)
                .resizable()
                .scaledToFit()
                .frame(width: 44.s, height: 44.s)
                .opacity(0.35)

            Text(tab.titleKey.localized)
                .font(.app(.bold, size: 22))
                .foregroundStyle(Color(app: .dark))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(app: .white))
    }
}
