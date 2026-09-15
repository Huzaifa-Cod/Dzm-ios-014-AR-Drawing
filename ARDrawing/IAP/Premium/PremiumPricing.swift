//
//  PremiumPricing.swift
//  ARDrawing
//


import Foundation

struct PremiumPricing {
    /// Headline price on the weekly card.
    var weeklyPrice: String
    /// What a week works out at per day, for the card's footnote.
    var weeklyPerDay: String

    /// Headline price on the yearly card, after the discount.
    var yearlyPrice: String
    /// Struck through above `yearlyPrice`. Nil hides the strikethrough.
    var yearlyOriginalPrice: String?
    var yearlyPerDay: String

    func headlinePrice(for plan: PremiumPlan) -> String {
        switch plan {
        case .weekly: return weeklyPrice
        case .yearly: return yearlyPrice
        }
    }

    func originalPrice(for plan: PremiumPlan) -> String? {
        switch plan {
        case .weekly: return nil
        case .yearly: return yearlyOriginalPrice
        }
    }

    func perDayPrice(for plan: PremiumPlan) -> String {
        switch plan {
        case .weekly: return weeklyPerDay
        case .yearly: return yearlyPerDay
        }
    }

    static let placeholder = PremiumPricing(
        weeklyPrice: "$11.99",
        weeklyPerDay: "$0.99",
        yearlyPrice: "$5.99",
        yearlyOriginalPrice: "$9.99",
        yearlyPerDay: "$0.86"
    )
}
