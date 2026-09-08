//
//  TutorialCallout.swift
//  ARDrawing
//
//  White instruction card with a dark badge straddling its top edge,
//  used through the drawing tutorial.
//

import SwiftUI

struct TutorialCallout: View {
    let badge: String
    let message: String

    /// Height of the badge pill. The card is pushed down by half of it so
    /// the badge sits centred on the card's top edge without the pill
    /// spilling outside the layout.
    private let badgeHeight: CGFloat = 30

    /// The card sits on an almost-white dotted background, where a black
    /// shadow only dims the paper slightly and disappears. Tinting it with
    /// the accent blue shifts the hue instead, so it stays visible at a
    /// lower opacity. Two layers do the work: a tight one to anchor the
    /// bottom edge, and a wide diffuse one for the sense of height.
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
