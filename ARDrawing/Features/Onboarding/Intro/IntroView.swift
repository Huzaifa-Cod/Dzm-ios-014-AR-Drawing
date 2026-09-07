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
            CollageImage(image: .onboard1, cornerRadius: 0)
                .frame(maxWidth: .infinity)
                .frame(height: 420.h)

            content
                .padding(.horizontal, 24.w)
                .padding(.top, 24.h)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .background(Color(.white).ignoresSafeArea())
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
                    .foregroundStyle(Color(.dark))
                    .multilineTextAlignment(.center)

                Text(LocalizedKey.introSubtitle.localized)
                    .font(.app(.regular, size: 14))
                    .foregroundStyle(Color(.textSecondary))
                    .multilineTextAlignment(.center)
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
                .foregroundStyle(Color(.textSecondary))
            + Text(LocalizedKey.introTermsOfUse.localized)
                .foregroundStyle(Color(.primaryBlue))
            + Text(" \(LocalizedKey.introTermsAnd.localized) ")
                .foregroundStyle(Color(.textSecondary))
            + Text(LocalizedKey.introPrivacyPolicy.localized)
                .foregroundStyle(Color(.primaryBlue))
        )
        .font(.app(.regular, size: 12))
        .multilineTextAlignment(.center)
    }
}

#Preview {
    NavigationStack {
        IntroView()
    }
    .environmentObject(AppRouter())
}
