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
}

/// Root of the navigation hierarchy. Splash is shown outside the
/// NavigationStack so it can own the initial fade/replace transition.
struct RootView: View {
    @StateObject private var router = AppRouter()
    @State private var isSplashFinished = false

    var body: some View {
        NavigationStack(path: $router.path) {
            Group {
                if isSplashFinished {
                    IntroView()
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
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .intro:
            IntroView()
        case .onboarding:
            OnboardingView()
        case .home:
            ContentView()
        }
    }
}
