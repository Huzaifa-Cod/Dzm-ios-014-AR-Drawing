//
//  OnboardingViewModel.swift
//  ARDrawing
//

import Combine
import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentPage: OnboardingPage = .trace

    func continueTapped(router: AppRouter) {
        UserDefaultsManager.shared.lastOnboardingPage = currentPage.rawValue

        guard let nextPage = OnboardingPage(rawValue: currentPage.rawValue + 1) else {
            UserDefaultsManager.shared.hasCompletedOnboarding = true
            router.push(.home)
            return
        }
        currentPage = nextPage
    }
}
