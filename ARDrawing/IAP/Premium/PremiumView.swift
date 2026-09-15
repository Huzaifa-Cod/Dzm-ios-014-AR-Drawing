//
//  PremiumView.swift
//  ARDrawing

import SwiftUI

struct PremiumView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPlan: PremiumPlan = .yearly

    private let pricing = PremiumPricing.placeholder

    private let pageMargin: CGFloat = 24
    private let planRadius: CGFloat = 26
    private let featurePlate: CGFloat = 58
    private let planCardHeight: CGFloat = 152

    private let iconScale: CGFloat = 1.2

    private let planOuterRing: CGFloat = 4
    private let planInnerRing: CGFloat = 2
 
    @EnvironmentObject private var iap: IAPManager
    @State private var alertMessage: String?

    private let heroBleed: CGFloat = 1
    private let heroOverlap: CGFloat = 80
    private let haloWidth: CGFloat = 8
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(app: .white).ignoresSafeArea()

            VStack(spacing: 0) {
                hero
                    .padding(.bottom, -heroOverlap.h)

                title

                Spacer(minLength: 10.h)

                featureRow

                Spacer(minLength: 14.h)

                planRow

                Spacer(minLength: 14.h)

                startButton

                trialNote
                    .padding(.top, 14.h)

                commitmentNote
                    .padding(.top, 6.h)

                Spacer(minLength: 10.h)

                footerLinks
            }
            .padding(.bottom, 10.h)
            .ignoresSafeArea(edges: .top)

            closeButton

            busyOverlay
        }
        .navigationBarBackButtonHidden(true)
        .alert(
            LocalizedKey.premiumFailedMessage.localized,
            isPresented: Binding(
                get: { alertMessage != nil },
                set: { if !$0 { alertMessage = nil } }
            ),
            presenting: alertMessage
        ) { _ in
            Button("OK", role: .cancel) { alertMessage = nil }
        } message: { message in
            Text(message)
        }
    }

    // MARK: Hero

    private var hero: some View {
        Image(.premiumImg)
            .resizable()
            .scaledToFit()
            .scaleEffect(heroBleed)
//            .clipped()
            .overlay {
                Image(app: .whiteOverlay)
                    .resizable()
            }
    }

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 17.s, weight: .bold))
                .foregroundStyle(Color(app: .dark))
                .frame(width: 32.s, height: 32.s)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.horizontal, pageMargin.w)
        .padding(.top, 8.h)
    }

    // MARK: Title

    private var title: some View {
        Text(LocalizedKey.premiumTitle.localized)
            .font(.app(.fredoka, size: 32))
            .foregroundStyle(Color(app: .dark))
            .multilineTextAlignment(.center)
    }

    // MARK: Features

    private var featureRow: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(PremiumFeature.allCases) { feature in
                VStack(spacing: 10.h) {
                    Image(app: feature.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(height: (feature.iconHeight * iconScale).s)
                        .frame(width: featurePlate.s, height: featurePlate.s)
                        .background(Circle().fill(Color(app: .accent)))

                    Text(feature.titleKey.localized)
                        .font(.app(.medium, size: 13))
                        .foregroundStyle(Color(app: .dark))
                        .multilineTextAlignment(.center)
                        .lineSpacing(1.h)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, pageMargin.w)
    }

    // MARK: Plans

    private var planRow: some View {
        HStack(alignment: .top, spacing: 12.w) {
            ForEach(PremiumPlan.allCases) { plan in
                planCard(plan)
            }
        }
        .padding(.horizontal, pageMargin.w)
    }
    
    private func planCard(_ plan: PremiumPlan) -> some View {
        let isSelected = plan == selectedPlan

        return Button {
            withAnimation(.easeOut(duration: 0.15)) {
                selectedPlan = plan
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                Text(pricing.originalPrice(for: plan) ?? " ")
                    .font(.app(.medium, size: 14))
                    .strikethrough(pricing.originalPrice(for: plan) != nil)
                    .foregroundStyle(
                        isSelected
                            ? Color(app: .white).opacity(0.75)
                            : Color(app: .textSecondary)
                    )

                Text(pricing.headlinePrice(for: plan))
                    .font(.app(.bold, size: 30))
                    .foregroundStyle(isSelected ? Color(app: .white) : Color(app: .dark))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Spacer(minLength: 8.h)

                Text(plan.titleKey.localized)
                    .font(.app(.bold, size: 17))
                    .foregroundStyle(isSelected ? Color(app: .white) : Color(app: .dark))

                Text(LocalizedKey.premiumPlanFootnote.localized(pricing.perDayPrice(for: plan)))
                    .font(.app(.regular, size: 11))
                    .foregroundStyle(
                        isSelected
                            ? Color(app: .white).opacity(0.85)
                            : Color(app: .textSecondary)
                    )
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4.h)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16.w)
            .padding(.vertical, 16.h)
            .frame(height: planCardHeight.h, alignment: .topLeading)
            .background { planBackground(isSelected: isSelected) }
            .overlay(alignment: .topTrailing) {
                Image(app: isSelected ? .pCheckIcon : .pUncheckIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24.s, height: 24.s)
                    .padding(14.s)
            }
            .overlay(alignment: .top) {
                if plan == .yearly {
                    saveBadge
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: planRadius.s, style: .continuous))
        }
        .buttonStyle(.plain)
    }
 
    @ViewBuilder
       private func planBackground(isSelected: Bool) -> some View {
           if isSelected {
               ZStack {
                   RoundedRectangle(cornerRadius: (planRadius + haloWidth).s, style: .continuous)
                       .fill(Color(app: .accent).opacity(0.18))
                       .padding(-haloWidth.s)

                   RoundedRectangle(cornerRadius: (planRadius + haloWidth).s, style: .continuous)
                       .strokeBorder(Color(app: .accent), lineWidth: 1.5)
                       .padding(-haloWidth.s)

                   RoundedRectangle(cornerRadius: planRadius.s, style: .continuous)
                       .fill(Color(app: .accent))
               }
           } else {
               RoundedRectangle(cornerRadius: planRadius.s, style: .continuous)
                   .fill(Color(app: .planUnselected))
                   .overlay(
                       RoundedRectangle(cornerRadius: planRadius.s, style: .continuous)
                           .strokeBorder(Color(app: .dark).opacity(0.08), lineWidth: 1)
                   )
           }
       }

    private var saveBadge: some View {
        Text(LocalizedKey.premiumSaveBadge.localized)
            .font(.app(.bold, size: 11))
            .foregroundStyle(Color(app: .white))
            .padding(.horizontal, 12.w)
            .frame(height: 24.h)
            .background(Capsule().fill(Color(app: .redAccent)))
            .offset(y: -12.h)
    }

    // MARK: Call to action

    private var startButton: some View {
        Button {
            startPurchase()
        } label: {
            HStack(spacing: 8.w) {
                Image(app: .whiteCrownIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18.s, height: 14.s)

                Text(LocalizedKey.premiumStartFree.localized)
                    .font(.app(.bold, size: 18))
            }
            .foregroundStyle(Color(app: .white))
            .frame(maxWidth: .infinity)
            .frame(height: 60.h)
            .background(
                Capsule().fill(
                    LinearGradient(
                        colors: [Color(app: .premiumGold), Color(app: .proOrange)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, pageMargin.w)
    }

    private var trialNote: some View {
        Text(
            LocalizedKey.premiumTrialNote.localized(
                pricing.headlinePrice(for: selectedPlan),
                selectedPlan.periodKey.localized
            )
        )
        .font(.app(.semiBold, size: 14))
        .foregroundStyle(Color(app: .dark))
        .multilineTextAlignment(.center)
        .padding(.horizontal, pageMargin.w)
    }

    private var commitmentNote: some View {
        Text(LocalizedKey.premiumCommitmentNote.localized)
            .font(.app(.regular, size: 13))
            .foregroundStyle(Color(app: .textSecondary))
            .multilineTextAlignment(.center)
            .padding(.horizontal, pageMargin.w)
    }

    // MARK: Footer

    private var footerLinks: some View {
        HStack(spacing: 10.w) {
            footerLink(.premiumTermsOfUse) {
                // Opens the terms page with the legal links work.
            }
            footerSeparator
            footerLink(.premiumPrivacyPolicy) {
                // Opens the privacy page with the legal links work.
            }
            footerSeparator
            footerLink(.premiumRestore) {
                restore()
            }
        }
        .padding(.horizontal, pageMargin.w)
    }

    private func footerLink(_ key: LocalizedKey, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(key.localized)
                .font(.app(.regular, size: 13))
                .foregroundStyle(Color(app: .textSecondary))
        }
        .buttonStyle(.plain)
    }

    private var footerSeparator: some View {
        Rectangle()
            .fill(Color(app: .dark).opacity(0.15))
            .frame(width: 1, height: 12.h)
    }

    // MARK: Purchasing

    private func startPurchase() {
        iap.purchase(selectedPlan.productId) { success, message in
            if success {
                dismiss()
            } else if let message {
                // A cancel comes back with no message — nothing went
                // wrong, so nothing is worth interrupting them for.
                alertMessage = message
            }
        }
    }

    private func restore() {
        iap.restorePurchases { success, message in
            if success {
                dismiss()
            } else {
                alertMessage = message ?? LocalizedKey.premiumRestoreNoneFound.localized
            }
        }
    }

    /// Covers both the purchase sheet and the restore round-trip, so the
    /// screen can't be tapped through while either is in flight.
    private var isBusy: Bool { iap.purchaseInProgress || iap.isRestoring }

    private var busyOverlay: some View {
        Group {
            if isBusy {
                ZStack {
                    Color(app: .black).opacity(0.25).ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(Color(app: .white))
                        .scaleEffect(1.3)
                }
                .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.2), value: isBusy)
    }
}

//#Preview {
//    PremiumView()
//}
