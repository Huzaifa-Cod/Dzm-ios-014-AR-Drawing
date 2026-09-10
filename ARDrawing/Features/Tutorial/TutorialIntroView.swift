//
//  TutorialIntroView.swift
//  ARDrawing
//

import SwiftUI

struct TutorialIntroView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = TutorialIntroViewModel()

    var body: some View {
        VStack(spacing: 0) {
            Text(LocalizedKey.tutorialTitle.localized)
                .font(.app(.bold, size: 24))
                .foregroundStyle(Color(app: .dark))
                .multilineTextAlignment(.center)
                .lineSpacing(4.h)
                .padding(.top, 30.h)

            // Scales with the screen so the cat keeps the same share of
            // the canvas on every device.
            Image(app: .previewCat)
                .resizable()
                .scaledToFit()
                .frame(width: 200.w)
                .padding(.top, 70.h)

            TutorialCallout(
                badge: LocalizedKey.tutorialBadge.localized,
                message: LocalizedKey.tutorialCallout.localized
            )
            .padding(.horizontal, 20.w)
            .padding(.top, 50.h)

            Image(app: .pointedArrowIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 105.w)
                .offset(x: -20.w)
                .padding(.top, 30.h)

            Spacer(minLength: 0)

            PrimaryButton(title: LocalizedKey.tutorialStartButton.localized) {
                viewModel.startTutorial(router: router)
            }

            Button {
                viewModel.skipTutorial(router: router)
            } label: {
                Text(LocalizedKey.tutorialSkipButton.localized)
                    .font(.app(.medium, size: 14))
                    .foregroundStyle(Color(app: .textSecondary))
            }
            .padding(.top, 16.h)
        }
        .padding(.horizontal, 24.w)
        .padding(.bottom, 12.h)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Drawn as a background so the dotted paper bleeds edge to edge
        // while the content above still respects the safe area.
        .background {
            Image(app: .tutorialOnboardBgImg)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
        .navigationBarBackButtonHidden(true)
    }
}

//#Preview {
//    NavigationStack {
//        TutorialIntroView()
//    }
//    .environmentObject(AppRouter())
//}
