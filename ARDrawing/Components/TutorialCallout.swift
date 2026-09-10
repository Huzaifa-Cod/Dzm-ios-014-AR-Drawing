//
//  TutorialCallout.swift
//  ARDrawing
//


import SwiftUI

struct TutorialCallout: View {
    let badge: String
    let message: String

    private let badgeHeight: CGFloat = 30
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20.s, style: .continuous)
            .fill(Color(app: .white))
            .shadow(color: Color(app: .accent).opacity(0.10), radius: 4.s, y: 2.h)
            .shadow(color: Color(app: .accent).opacity(0.18), radius: 22.s, y: 12.h)
    }

    var body: some View {
        ZStack(alignment: .top) {
            Text(message)
                .font(.app(.regular, size: 14))
                .foregroundStyle(Color(app: .dark))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16.w)
                .padding(.vertical, 16.h)
                .frame(maxWidth: .infinity)
                .background(cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 20.s, style: .continuous)
                        .stroke(Color(app: .tutorialBorder), lineWidth: 1)
                )
                .padding(.top, badgeHeight.h / 2)

            Text(badge)
                .font(.app(.semiBold, size: 13))
                .foregroundStyle(Color(app: .white))
                .frame(height: badgeHeight.h)
                .padding(.horizontal, 16.w)
                .background(Capsule().fill(Color(app: .dark)))
        }
    }
}
