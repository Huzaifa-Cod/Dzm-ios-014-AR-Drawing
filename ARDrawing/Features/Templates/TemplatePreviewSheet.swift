//  TemplatePreviewSheet.swift
//  ARDrawing


import SDWebImageSwiftUI
import SwiftUI


struct TemplatePreviewSelection: Identifiable {
    let category: TemplateCategoryData
    let index: Int
    let url: URL

    var id: String { "\(category.folderName)-\(index)" }
}

struct TemplatePreviewSheet: View {
    @Environment(\.dismiss) private var dismiss

    let selection: TemplatePreviewSelection
    let onStartDrawing: (URL) -> Void

    private let imageSize: CGFloat = 176
    private let imageRadius: CGFloat = 30

    private var difficulty: TemplateDifficulty {
        TemplateDifficultyRules.difficulty(forIndex: selection.index)
    }

    private var title: String {
        "\(selection.category.categoryName) \(selection.index)"
    }

    var body: some View {
        VStack(spacing: 0) {
            image
                .padding(.top, 40.h)

            Text(title)
                .font(.app(.paytoneOne, size: 24))
                .foregroundStyle(Color(app: .dark))
                .padding(.top, 18.h)

            Text(LocalizedKey.drawModeDescription.localized)
                .font(.app(.regular, size: 15))
                .foregroundStyle(Color(app: .textSecondary))
                .multilineTextAlignment(.center)
                .lineSpacing(3.h)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 6.h)
                .padding(.horizontal, 12.w)

            infoRow
                .padding(.top, 20.h)

            Spacer(minLength: 24.h)

            actionButton

            Button {
                dismiss()
            } label: {
                Text(LocalizedKey.templatePreviewClose.localized)
                    .font(.app(.bold, size: 16))
                    .foregroundStyle(Color(app: .textSecondary))
            }
            .buttonStyle(.plain)
            .padding(.top, 14.h)
        }
        .padding(.horizontal, 24.w)
        .padding(.bottom, 16.h)
        .frame(maxWidth: .infinity)
        .background(Color(app: .white).ignoresSafeArea())
        .presentationDetents([.fraction(0.72)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
        .presentationBackground(Color(app: .white))
    }

    // MARK: Image + badge

    private var image: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: imageRadius.s, style: .continuous)
                .stroke(Color(app: .dark).opacity(0.1), lineWidth: 1.5)
                .frame(width: imageSize.w, height: imageSize.w)
                .overlay {
                    WebImage(url: selection.url) { img in
                        img.resizable().scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .padding(24.s)
                }

            badge
                .offset(y: 14.h)
        }
        .padding(.bottom, 14.h)
    }

    private var badge: some View {
        Text(
            difficulty.requiresPro
                ? LocalizedKey.templatePreviewProBadge.localized
                : LocalizedKey.templatePreviewFreeBadge.localized
        )
        .font(.app(.paytoneOne, size: 18))
        .foregroundStyle(Color(app: .white))
        .padding(.horizontal, 15.w)
        .frame(height: 28.h)
        .background(
            Capsule().fill(difficulty.requiresPro ? Color(app: .proOrange) : Color(app: .successGreen))
        )
        .shadow(color: .black.opacity(0.15), radius: 4.s, y: 2.h)
    }

    // MARK: Level / Avg time

    private var infoRow: some View {
        HStack(spacing: 0) {
            infoColumn(
                label: LocalizedKey.templatePreviewLevelLabel.localized,
                value: difficulty.titleKey.localized
            )

            Rectangle()
                .fill(Color(app: .dark).opacity(0.08))
                .frame(width: 1, height: 38.h)

            infoColumn(
                label: LocalizedKey.templatePreviewAvgLabel.localized,
                value: String(format: LocalizedKey.templatePreviewAvgMinutesFormat.localized, difficulty.averageMinutes)
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18.h)
        .background(
            RoundedRectangle(cornerRadius: 19.s, style: .continuous)
                .fill(Color(app: .accent).opacity(0.02))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 19.s, style: .continuous)
                .stroke(Color(app: .accent).opacity(0.10), lineWidth: 1)
        )
    }

    private func infoColumn(label: String, value: String) -> some View {
        VStack(spacing: 5.h) {
            Text(label)
                .font(.app(.regular, size: 14))
                .foregroundStyle(Color(app: .textSecondary))

            Text(value)
                .font(.app(.paytoneOne, size: 19))
                .foregroundStyle(Color(app: .dark))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Action

    @ViewBuilder
    private var actionButton: some View {
        if difficulty.requiresPro {
            Button {
                // No paywall yet — this is where it hooks in.
            } label: {
                Text(LocalizedKey.templatePreviewUnlockPro.localized)
                    .font(.app(.bold, size: 19))
                    .foregroundStyle(Color(app: .white))
                    .frame(maxWidth: .infinity)
                    .frame(height: 60.h)
                    .background(
                        LinearGradient(
                            colors: [Color(app: .proOrange), Color(red: 1.0, green: 0.75, blue: 0.35)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16.s, style: .continuous))
            }
            .buttonStyle(.plain)
        } else {
            PrimaryButton(title: LocalizedKey.templatePreviewStartDrawing.localized) {
                dismiss()
                onStartDrawing(selection.url)
            }
        }
    }
}
