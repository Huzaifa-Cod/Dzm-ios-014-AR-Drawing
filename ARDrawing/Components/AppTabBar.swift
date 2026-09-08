//
//  AppTabBar.swift
//  ARDrawing
//


import SwiftUI

struct AppTabBar: View {
    @Binding var selection: AppTab

    private let cornerRadius: CGFloat = 24

    /// Tallest icon, used to reserve a consistent row height so the labels
    /// line up even though the icons differ in size.
    private var iconRowHeight: CGFloat {
        AppTab.allCases.map(\.iconHeight).max() ?? 26
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                item(for: tab)
            }
        }
        .padding(.top, 12.h)
        .padding(.bottom, 6.h)
        .background {
            UnevenRoundedRectangle(
                topLeadingRadius: cornerRadius.s,
                topTrailingRadius: cornerRadius.s,
                style: .continuous
            )
            .fill(Color(app: .white))
            .shadow(color: Color(app: .dark).opacity(0.07), radius: 14.s, y: -4.h)
            // The bar's own padding stops at the safe area; the white has
            // to carry on past it so nothing shows through underneath.
            .ignoresSafeArea(edges: .bottom)
        }
    }

    private func item(for tab: AppTab) -> some View {
        let isSelected = selection == tab

        return Button {
            selection = tab
        } label: {
            VStack(spacing: 6.h) {
                Image(app: isSelected ? tab.activeImage : tab.inactiveImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: tab.iconHeight.s)
                    .frame(height: iconRowHeight.s)

                Text(tab.titleKey.localized)
                    .font(.app(isSelected ? .semiBold : .medium, size: 12))
                    .foregroundStyle(isSelected ? Color(app: .accent) : Color(app: .dark))
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
