//
//  OnboardingView.swift
//  ARDrawing
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var didAppear = false

    var body: some View {
        VStack(spacing: 0) {
            CollageImage(image: viewModel.currentPage.image, cornerRadius: 24)
                .frame(height: 340.h)
                .padding(.horizontal, 20.w)
                .padding(.top, 12.h)

            VStack(spacing: 18.h) {
                Image(app: .trustedByCreators)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 28.h)

                VStack(spacing: 10.h) {
                    Text(viewModel.currentPage.titleKey.localized)
                        .font(.app(.bold, size: 26))
                        .foregroundStyle(Color(.dark))
                        .multilineTextAlignment(.center)

                    Text(viewModel.currentPage.descriptionKey.localized)
                        .font(.app(.regular, size: 14))
                        .foregroundStyle(Color(.textSecondary))
                        .multilineTextAlignment(.center)
                }

                PrimaryButton(title: LocalizedKey.onboardingContinueButton.localized) {
                    viewModel.continueTapped(router: router)
                }
            }
            .padding(.horizontal, 24.w)
            .padding(.top, 28.h)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .background(Color(.white).ignoresSafeArea())
        .opacity(didAppear ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { didAppear = true }
        }
        .navigationBarBackButtonHidden(true)
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentPage)
    }
}

//#Preview {
//    NavigationStack {
//        OnboardingView()
//    }
//    .environmentObject(AppRouter())
//}
