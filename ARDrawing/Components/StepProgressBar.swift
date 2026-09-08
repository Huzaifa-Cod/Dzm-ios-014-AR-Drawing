//
//  StepProgressBar.swift
//  ARDrawing
//
//  Segmented progress bar shown above the drawing tutorial.
//

import SwiftUI

struct StepProgressBar: View {
    let total: Int
    let completed: Int

    var body: some View {
        HStack(spacing: 4.s) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index < completed ? Color(app: .accent) : Color(app: .dotInactive))
                    .frame(width: 16.s, height: 6.s)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: completed)
    }
}
