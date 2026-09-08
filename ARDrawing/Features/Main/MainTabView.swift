//
//  MainTabView.swift
//  ARDrawing
//

import SwiftUI

struct MainTabView: View {
    @State private var selection: AppTab = .home
    @State private var hasContentBelow = false

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

            AppTabBar(selection: $selection)
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
        switch selection {
        case .home: HomeView()
        case .lessons: TabPlaceholderView(tab: .lessons)
        case .templates: TemplatesView()
        case .profile: TabPlaceholderView(tab: .profile)
        case .settings: TabPlaceholderView(tab: .settings)
        }
    }
}

#Preview {
    NavigationStack {
        MainTabView()
    }
    .environmentObject(AppRouter())
}
