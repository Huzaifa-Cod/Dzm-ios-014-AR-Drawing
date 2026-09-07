//
//  PrimaryButton.swift
//  ARDrawing
//
//  Shared full-width rounded CTA button used across onboarding
//  and the rest of the app.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    var action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.app(.semiBold, size: 17))
                .foregroundStyle(Color(.white))
                .frame(maxWidth: .infinity)
                .frame(height: 56.h)
                .background(Color(.primaryBlue))
                .clipShape(RoundedRectangle(cornerRadius: 16.s, style: .continuous))
        }
        .scaleEffect(isPressed ? 0.97 : 1)
        .animation(.easeOut(duration: 0.15), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}
