//
//  OnboardingArtworkView.swift
//  ARDrawing
//
//  The artwork block of one onboarding page.
//
//  The artwork sits in a fixed-height band so the page indicator and the
//  copy below never shift between pages. The image keeps its own aspect
//  ratio (never cropped at the sides) and is pinned to the top of the
//  band; the white fade and the "Trusted by the creatives" badge are
//  pinned to the *bottom of the band*, so they land in the same place on
//  every page and the fade hides the edge of any artwork shorter than
//  the band.
//

import SwiftUI

struct OnboardingArtworkView: View {
    let page: OnboardingPage
    let height: CGFloat

    var body: some View {
        Color(app: .white)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .overlay(alignment: .top) {
                Image(app: page.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .clipped()
            // Fades the artwork's top edge into the screen so it never
            // shows a hard border under the status bar.
            .overlay(alignment: .top) {
                LinearGradient(
                    stops: [
                        .init(color: Color(app: .white), location: 0),
                        .init(color: Color(app: .white).opacity(0.55), location: 0.45),
                        .init(color: Color(app: .white).opacity(0), location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 90.h)
                .allowsHitTesting(false)
            }
            .overlay(alignment: .bottom) {
                LinearGradient(
                    stops: [
                        .init(color: Color(app: .white).opacity(0), location: 0),
                        .init(color: Color(app: .white).opacity(0.92), location: 0.55),
                        .init(color: Color(app: .white), location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 150.h)
                .allowsHitTesting(false)
            }
            .overlay(alignment: .bottom) {
                if page.showsTrustBadge {
                    Image(app: .trustedByCreators)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 165.w)
                }
            }
    }
}
