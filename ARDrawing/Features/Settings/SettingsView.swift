//
//  SettingsView.swift
//  ARDrawing
//

import SwiftUI

struct SettingsView: View {
    private let pageMargin: CGFloat = 20
    private let cardRadius: CGFloat = 20
    private let iconPlateSize: CGFloat = 36

    var body: some View {
        ReportingScrollView {
            VStack(spacing: 20.h) {
                header

                ForEach(SettingsSection.allCases) { section in
                    sectionCard(section)
                }
            }
            .padding(.horizontal, pageMargin.w)
            .padding(.top, 8.h)
            .padding(.bottom, 16.h)
        }
        .background(Color(app: .homeBackground).ignoresSafeArea())
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 8.w) {
            Text(LocalizedKey.settingsTitle.localized)
                .font(.app(.paytoneOne, size: 24))
                .foregroundStyle(Color(app: .dark))

            Spacer(minLength: 8.w)

            StreakPill()
            ProPill()
        }
    }

    // MARK: Sections

    private func sectionCard(_ section: SettingsSection) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(section.titleKey.localized)
                .font(.app(.medium, size: 13))
                .foregroundStyle(Color(app: .textSecondary))
                .padding(.horizontal, 16.w)
                .padding(.top, 14.h)
                .padding(.bottom, 8.h)

            VStack(spacing: 0) {
                ForEach(Array(section.rows.enumerated()), id: \.element) { index, row in
                    if index > 0 {
                        Divider()
                            .overlay(Color(app: .dark).opacity(0.06))
                            .padding(.leading, 16.w + iconPlateSize.s + 12.w)
                    }

                    settingsRow(row)
                }
            }
            .padding(.bottom, 6.h)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: cardRadius.s, style: .continuous).fill(Color(app: .white)))
    }

    private func settingsRow(_ row: SettingsRow) -> some View {
        Button {
            // Each destination lands with its own feature — Language,
            // Rate Us, and the rest all still route here for now.
        } label: {
            HStack(spacing: 12.w) {
                Image(app: row.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18.s, height: 18.s)
                    .foregroundStyle(Color(app: .dark))
                    .frame(width: iconPlateSize.s, height: iconPlateSize.s)
                    .background(Circle().fill(Color(app: .homeBackground)))

                Text(row.titleKey.localized)
                    .font(.app(.semiBold, size: 15))
                    .foregroundStyle(Color(app: .dark))

                Spacer(minLength: 8.w)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13.s, weight: .semibold))
                    .foregroundStyle(Color(app: .textSecondary))
            }
            .padding(.horizontal, 16.w)
            .frame(height: 56.h)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView()
}
