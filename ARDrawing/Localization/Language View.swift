//
//  Language View.swift
//  ARDrawing
//

import SwiftUI

struct LanguageSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selected: AppLanguage = UserDefaultsManager.shared.selectedLanguage

    private let pageMargin: CGFloat = 20
    private let cardRadius: CGFloat = 20
    private let flagPlateSize: CGFloat = 36

    var body: some View {
        VStack(spacing: 0) {
            header

            ReportingScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(AppLanguage.allCases.enumerated()), id: \.element) { index, language in
                        if index > 0 {
                            Divider()
                                .overlay(Color(app: .dark).opacity(0.06))
                                .padding(.leading, 16.w + flagPlateSize.s + 12.w)
                        }

                        languageRow(language)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: cardRadius.s, style: .continuous)
                        .fill(Color(app: .white))
                )
                .padding(.horizontal, pageMargin.w)
                .padding(.top, 20.h)
                .padding(.bottom, 16.h)
            }
        }
        .background(Color(app: .homeBackground).ignoresSafeArea())
        .navigationBarHidden(true)
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 8.w) {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 8.w) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15.s, weight: .bold))

                    Text(LocalizedKey.settingsLanguage.localized)
                        .font(.app(.paytoneOne, size: 24))
                }
                .foregroundStyle(Color(app: .dark))
            }
            .buttonStyle(.plain)

            Spacer(minLength: 8.w)
        }
        .padding(.horizontal, pageMargin.w)
        .padding(.top, 14.h)
        .padding(.bottom, 16.h)
        .frame(maxWidth: .infinity)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 22.s,
                bottomTrailingRadius: 22.s,
                topTrailingRadius: 0,
                style: .continuous
            )
            .fill(Color(app: .white))
            .ignoresSafeArea(edges: .top)
        )
    }

    // MARK: Row

    private func languageRow(_ language: AppLanguage) -> some View {
        let isSelected = language == selected

        return Button {
            select(language)
        } label: {
            HStack(spacing: 12.w) {
                Text(language.flag)
                    .font(.system(size: 18.s))
                    .frame(width: flagPlateSize.s, height: flagPlateSize.s)
                    .background(Circle().fill(Color(app: .homeBackground)))

                Text(language.nativeName)
                    .font(.app(.semiBold, size: 15))
                    .foregroundStyle(Color(app: .dark))

                Spacer(minLength: 8.w)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20.s, weight: .semibold))
                        .foregroundStyle(Color(app: .accent))
                } else {
                    Circle()
                        .stroke(Color(app: .dark).opacity(0.15), lineWidth: 1.5)
                        .frame(width: 20.s, height: 20.s)
                }
            }
            .padding(.horizontal, 16.w)
            .frame(height: 56.h)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: Actions

    private func select(_ language: AppLanguage) {
        guard language != selected else { return }
        withAnimation(.easeOut(duration: 0.15)) {
            selected = language
        }
        // Persists the choice and swaps every `.localized` lookup over
        // to it — `RootView` keys its hierarchy off this and rebuilds,
        // so the whole app (this screen included) updates immediately.
        LocalizationManager.shared.setLanguage(language)
    }
}
