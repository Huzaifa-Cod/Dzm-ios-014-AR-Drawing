//
//  IntroViewModel.swift
//  ARDrawing
//

import Combine
import Foundation

@MainActor
final class IntroViewModel: ObservableObject {
    func agreeTapped(router: AppRouter) {
        UserDefaultsManager.shared.hasAgreedToTerms = true
        router.push(.onboarding)
    }
}
