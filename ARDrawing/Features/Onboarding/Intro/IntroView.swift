//
//  IntroView.swift
//  ARDrawing
//
//  First screen after Splash: a hero collage illustration (already
//  fully composed as a single asset by design) followed by the
//  "Agree & Continue" terms gate.
//

import SwiftUI

struct IntroView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = IntroViewModel()
    @State private var didAppear = false

    var body: some View {
        VStack(spacing: 0) {
            Image(app: .onboard1)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                // Fades the collage's top edge into the screen so it never
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

            content
                .padding(.horizontal, 20.w)
                .padding(.top, 24.h)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .background(Color(app: .white).ignoresSafeArea())
        .opacity(didAppear ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { didAppear = true }
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: Bottom content

    private var content: some View {
        VStack(spacing: 20.h) {
            VStack(spacing: 10.h) {
                Text(LocalizedKey.introTitle.localized)
                    .font(.app(.bold, size: 26))
                    .foregroundStyle(Color(app: .dark))
                    .multilineTextAlignment(.center)

                Text(LocalizedKey.introSubtitle.localized)
                    .font(.app(.regular, size: 14))
                    .foregroundStyle(Color(app: .textSecondary))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8.w)
            }

            PrimaryButton(title: LocalizedKey.introAgreeButton.localized) {
                viewModel.agreeTapped(router: router)
            }

            termsText
        }
    }

    private var termsText: some View {
        (
            Text("\(LocalizedKey.introTermsPrefix.localized) ")
                .foregroundStyle(Color(app: .textSecondary))
            + Text(LocalizedKey.introTermsOfUse.localized)
                .foregroundStyle(Color(app: .accent))
            + Text(" \(LocalizedKey.introTermsAnd.localized) ")
                .foregroundStyle(Color(app: .textSecondary))
            + Text(LocalizedKey.introPrivacyPolicy.localized)
                .foregroundStyle(Color(app: .accent))
        )
        .font(.app(.regular, size: 12))
        .multilineTextAlignment(.center)
    }
}

//#Preview {
//    NavigationStack {
//        IntroView()
//    }
//    .environmentObject(AppRouter())
//}
