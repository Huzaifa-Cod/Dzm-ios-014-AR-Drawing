//
//  TutorialCompleteView.swift
//  ARDrawing
//


import SwiftUI

struct TutorialCompleteView: View {
    @EnvironmentObject private var router: AppRouter

    let strokes: [DrawnStroke]

    /// Height of the sketch band. Fixed so the copy below it sits in the
    /// same place regardless of how the drawing turned out.
    private let sketchHeight: CGFloat = 250

    var body: some View {
        VStack(spacing: 0) {
            Image(app: .onboardProfileIcons)
                .resizable()
                .scaledToFit()
                .frame(height: 40.h)
                .padding(.top, 24.h)

            Text(LocalizedKey.tutorialCompleteSocialProof.localized)
                .font(.app(.bold, size: 15))
                .foregroundStyle(Color(app: .dark))
                .multilineTextAlignment(.center)
                .padding(.top, 14.h)

            sketch
                .frame(height: sketchHeight.h)
                .padding(.top, 24.h)

            Text(LocalizedKey.tutorialCompleteHeadline.localized)
                .font(.app(.bold, size: 24))
                .foregroundStyle(Color(app: .dark))
                .multilineTextAlignment(.center)
                .padding(.top, 28.h)

            Text(LocalizedKey.tutorialCompleteDescription.localized)
                .font(.app(.regular, size: 13))
                .foregroundStyle(Color(app: .textSecondary))
                .multilineTextAlignment(.center)
                .lineSpacing(3.h)
                .padding(.top, 10.h)
                .padding(.horizontal, 12.w)

            Spacer(minLength: 16.h)

            PrimaryButton(title: LocalizedKey.tutorialCompleteContinueButton.localized) {
                router.replaceStack(with: .home)
            }
            .padding(.bottom, 12.h)
        }
        .padding(.horizontal, 24.w)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(app: .white).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    /// The drawing, fitted into the band. Reuses the tutorial's own
    /// full-cat framing, so the strokes land here exactly where they sat on
    /// the final step — no second opinion about the geometry.
    private var sketch: some View {
        GeometryReader { geo in
            SketchCanvas(
                strokes: strokes,
                masterFrame: TutorialGuideSlice.full.masterFrame(fitting: geo.size)
            )
        }
    }
}
//
//#Preview {
//    NavigationStack {
//        TutorialCompleteView(strokes: [])
//    }
//    .environmentObject(AppRouter())
//}
