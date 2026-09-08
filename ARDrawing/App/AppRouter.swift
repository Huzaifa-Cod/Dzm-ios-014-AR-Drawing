//
//  AppRouter.swift
//  ARDrawing
//

import Combine
import SwiftUI

@MainActor
final class AppRouter: ObservableObject {
    @Published var path = NavigationPath()

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }

    /// Replaces the whole stack with a single destination. Used when a flow
    /// finishes and there is nothing behind it worth going back to.
    func replaceStack(with route: AppRoute) {
        var fresh = NavigationPath()
        fresh.append(route)
        path = fresh
    }
}

/// Root of the navigation hierarchy. Splash is shown outside the
/// NavigationStack so it can own the initial fade/replace transition.
struct RootView: View {
    @StateObject private var router = AppRouter()
    @State private var isSplashFinished = false

    /// Resolved once, when the view is first created, rather than read on
    /// every redraw. The flags change while the user is still inside these
    /// flows — finishing onboarding sets one — and re-reading them would
    /// swap the screen out from under a push that is already happening.
    @State private var launch = LaunchDestination.current

    var body: some View {
        NavigationStack(path: $router.path) {
            Group {
                if isSplashFinished {
                    launchDestination
                } else {
                    SplashView(isFinished: $isSplashFinished)
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                destination(for: route)
            }
        }
        .environmentObject(router)
    }

    @ViewBuilder
    private var launchDestination: some View {
        switch launch {
        case .intro: IntroView()
        case .onboarding: OnboardingView()
        case .tutorial: TutorialIntroView()
        case .main: MainTabView()
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .intro:
            IntroView()
        case .onboarding:
            OnboardingView()
        case .tutorial:
            TutorialIntroView()
        case .tutorialDrawing:
            TutorialDrawingView()
        case .tutorialComplete(let strokes):
            TutorialCompleteView(strokes: strokes)
        case .home:
            MainTabView()
        }
    }
}
