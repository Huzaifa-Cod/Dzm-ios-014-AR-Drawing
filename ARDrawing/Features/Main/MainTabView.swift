//
//  MainTabView.swift
//  ARDrawing
//

import SwiftUI
import Combine

@MainActor
final class TabRouter: ObservableObject {
    @Published var selection: AppTab = .home
    @Published var pendingCategoryID: String?

    func showTemplates(category: TemplateCategoryData) {
        pendingCategoryID = category.id
        selection = .templates
    }
}

struct MainTabView: View {
    @State private var selection: AppTab = .home
    @State private var hasContentBelow = false
    @EnvironmentObject private var tabRouter: TabRouter
    
    /// How far the content dissolves into the bar as it scrolls behind it.
    private let contentFadeHeight: CGFloat = 100

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .bottom) {
                    contentFade.opacity(hasContentBelow ? 1 : 0)
                }
                .onPreferenceChange(HasContentBelowKey.self) { hasMore in
                    withAnimation(.easeOut(duration: 0.2)) {
                        hasContentBelow = hasMore
                    }
                }

            AppTabBar(selection: $tabRouter.selection)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(app: .white).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    private var contentFade: some View {
        LinearGradient(
            colors: [Color(app: .white).opacity(0), Color(app: .white)],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: contentFadeHeight.h)
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private var content: some View {
        switch tabRouter.selection {
        case .home: HomeView()
        case .lessons: LessonsView()
        case .templates: TemplatesView()
        case .profile: ProfileView()
        case .settings: SettingsView()
        }
    }
}

//#Preview {
//    NavigationStack {
//        MainTabView()
//    }
//    .environmentObject(AppRouter())
//}
