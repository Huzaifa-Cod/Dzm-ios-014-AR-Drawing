//
//  TutorialIntroViewModel.swift
//  ARDrawing
//

import Combine
import Foundation

@MainActor
final class TutorialIntroViewModel: ObservableObject {
    func startTutorial(router: AppRouter) {
        router.push(.tutorialDrawing)
    }

    func skipTutorial(router: AppRouter) {
        UserDefaultsManager.shared.hasCompletedTutorial = true
        router.replaceStack(with: .home)
    }
}
