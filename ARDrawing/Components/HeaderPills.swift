//
//  HeaderPills.swift
//  ARDrawing
//
//  The streak counter and Pro badge that sit at the top right of Home and
//  Templates. Shared so the two screens cannot drift apart.
//

import SwiftUI

/// Flame icon plus the user's current streak.
struct StreakPill: View {
    var body: some View {
        HStack(spacing: 4.w) {
            Image(app: .fireIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 18.s, height: 18.s)

            Text(LocalizedKey.homeStreakCount.localized)
                .font(.app(.bold, size: 14))
                .foregroundStyle(Color(app: .dark))
        }
        .padding(.horizontal, 12.w)
        .frame(height: 34.h)
        .background(Capsule().fill(Color(app: .white)))
    }
}

/// Upgrade badge.
struct ProPill: View {
    var body: some View {
        HStack(spacing: 5.w) {
            Image(app: .starIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 19.s, height: 17.s)

            Text(LocalizedKey.homeProBadge.localized)
                .font(.app(.bold, size: 14))
                .foregroundStyle(Color(app: .white))
        }
        .padding(.horizontal, 14.w)
        .frame(height: 34.h)
        .background(Capsule().fill(Color(app: .proOrange)))
    }
}
