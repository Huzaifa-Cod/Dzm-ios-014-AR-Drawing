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
    @StateObject private var tabRouter = TabRouter()
    /// Shared with Home and Templates via `.environmentObject` so both
    /// read the same fetched catalog instead of each fetching its own.
    @StateObject private var templateCatalog = TemplateCatalogStore()
    @StateObject private var iap = IAPManager.shared
    @StateObject private var localization = LocalizationManager.shared
    @State private var isSplashFinished = false

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
        .environmentObject(templateCatalog)
        .environmentObject(tabRouter)
        .environmentObject(iap)
        .environmentObject(localization)
        // Rebuilds every screen — including ones already on the
        // navigation stack — the instant the language changes, so
        // switching in Settings needs no app restart.
        .id(localization.language)
        .environment(\.layoutDirection, localization.language.isRightToLeft ? .rightToLeft : .leftToRight)
        .task {
            iap.verifySubscriptions()
            iap.fetchProducts()
        }
        // `IAPManager.canProceed` is static and reachable from anywhere,
        // including call sites with no route to the router — it announces
        // that the allowance is spent, and this is what answers.
        .onReceive(NotificationCenter.default.publisher(for: .showPremiumScreen)) { _ in
            guard !iap.isPremiumUnlocked else { return }
            router.push(.premium)
        }
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
        case .album:
            AlbumView()
        case .drawModeSelection(let templateURL):
            DrawModeSelectionView(templateURL: templateURL)
        case .editor(let mode, let templateURL):
            EditorView(mode: mode, templateURL: templateURL)
        case .sketchResult(let id):
            SketchResultView(sketchID: id)
        case .achievements:
            AchievementsView()
        case .learningLevel:
            LearningLevelView()
        case .language:
            LanguageSettingsView()
        case .premium:
            PremiumView()
        }
    }
}
