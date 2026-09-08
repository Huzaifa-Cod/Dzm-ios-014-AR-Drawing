//
//  OnboardingViewModel.swift
//  ARDrawing
//

import Combine
import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentPage: OnboardingPage = .trace

    /// Advances to the next page, or finishes onboarding on the last one.
    func continueTapped(router: AppRouter) {
        guard OnboardingPage(rawValue: currentPage.rawValue + 1) != nil else {
            UserDefaultsManager.shared.hasCompletedOnboarding = true
            router.push(.tutorial)
            return
        }
        goToNextPage()
    }

    func goToNextPage() {
        guard let nextPage = OnboardingPage(rawValue: currentPage.rawValue + 1) else { return }
        currentPage = nextPage
        UserDefaultsManager.shared.lastOnboardingPage = nextPage.rawValue
    }

    func goToPreviousPage() {
        guard let previousPage = OnboardingPage(rawValue: currentPage.rawValue - 1) else { return }
        currentPage = previousPage
        UserDefaultsManager.shared.lastOnboardingPage = previousPage.rawValue
    }
}
