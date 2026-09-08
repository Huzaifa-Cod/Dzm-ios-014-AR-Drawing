//
//  PageIndicator.swift
//  ARDrawing
//
//  Dot pager used under the onboarding artwork. The active dot
//  stretches into a pill; the width change is the only thing animated.
//

import SwiftUI

struct PageIndicator: View {
    let count: Int
    let currentIndex: Int

    var body: some View {
        HStack(spacing: 6.s) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == currentIndex ? Color(app: .accent) : Color(app: .dotInactive))
                    .frame(width: index == currentIndex ? 22.s : 7.s, height: 7.s)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: currentIndex)
    }
}
