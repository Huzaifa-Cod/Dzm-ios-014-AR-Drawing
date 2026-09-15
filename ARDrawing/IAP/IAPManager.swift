//
//  IAPManager.swift
//  ARDrawing
//


import Combine
import Foundation
import StoreKit

// MARK: - Product IDs

enum PremiumProductId: String, CaseIterable {

    case yearly = "nz.testing.app.yearly"
    case weekly = "nz.testing.app.weekly"

    static var allIds: Set<String> {
        Set(PremiumProductId.allCases.map { $0.rawValue })
    }

    /// Order the plans appear in on the premium screen.
    static var displayOrder: [PremiumProductId] { [.weekly, .yearly] }
}

extension Notification.Name {
    static let iapPremiumStatusDidChange = Notification.Name("iapPremiumStatusDidChange")
    static let showPremiumScreen = Notification.Name("showPremiumScreen")
}

// MARK: - Premium Model

struct Premium: Codable, Identifiable {
    var id: String { productID ?? UUID().uuidString }
    var title: String!
    var titleDescp: String!
    var currancy: String!
    var productID: String!
    var price: Float? = 0.0
    var isSelected: Bool? = false
    var isTrial: Bool
    var trialDuration: String?
    var trialDurationNumber: Int?
    var userUsedTrial: Bool
}

// MARK: - IAPManager

@MainActor
final class IAPManager: ObservableObject {

    static let shared = IAPManager()

    @Published var isPremiumUnlocked: Bool = false
    @Published var isVerifying: Bool = true
    @Published var purchaseInProgress: Bool = false
    @Published var isRestoring: Bool = false
    @Published var errorMessage: String?
    /// Plans as shown on screen, in `displayOrder`.
    @Published var plans: [Premium] = []

    var products: [PremiumProductId: Product] = [:]
    var priceStrings: [PremiumProductId: String] = [:]

    private var updateListenerTask: Task<Void, Never>?

    init() {
        listenForTransactions()
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Fetch Products

    func fetchProducts(completion: (([Premium]?) -> Void)? = nil) {
        LocalSavedPremium.get(premiumDB: .premium) { premiums in
            if !premiums.isEmpty {
                self.plans = Self.sorted(premiums)
                completion?(self.plans)
            }
        }

        Task {
            do {
                let storeProducts = try await Product.products(for: Array(PremiumProductId.allIds))
                var newProducts: [PremiumProductId: Product] = [:]
                var newPriceStrings: [PremiumProductId: String] = [:]
                var premiumArray: [Premium] = []

                for product in storeProducts {
                    guard let premiumId = PremiumProductId(rawValue: product.id) else { continue }

                    newProducts[premiumId] = product
                    newPriceStrings[premiumId] = product.displayPrice

                    let priceValue = Double(truncating: product.price as NSNumber)
                    let currency = product.priceFormatStyle.currencyCode

                    var isTrial = false
                    var trialDuration: String?
                    var trialDurationNumber: Int?
                    var userUsedTrial = false

                    if let subscription = product.subscription {
                        if let trial = subscription.introductoryOffer, trial.paymentMode == .freeTrial {
                            isTrial = true
                            trialDuration = trial.period.unit.debugDescription.capitalized
                            trialDurationNumber = trial.period.value
                        }
                        let eligibility = await subscription.isEligibleForIntroOffer
                        userUsedTrial = !eligibility
                    }

                    premiumArray.append(Premium(
                        title: product.displayName,
                        titleDescp: product.description,
                        currancy: currency,
                        productID: product.id,
                        price: Float(priceValue),
                        isSelected: product.id == PremiumProductId.yearly.rawValue,
                        isTrial: isTrial,
                        trialDuration: trialDuration,
                        trialDurationNumber: trialDurationNumber,
                        userUsedTrial: userUsedTrial
                    ))

                    print("""
                    ------------------------
                    Product ID   : \(product.id)
                    Title        : \(product.displayName)
                    Price        : \(product.displayPrice)
                    Free Trial   : \(isTrial ? "\(trialDurationNumber ?? 0) \(trialDuration ?? "")" : "No Trial")
                    Trial Used   : \(userUsedTrial ? "✅ Already used" : "🆕 Eligible")
                    ------------------------
                    """)
                }

                self.products = newProducts
                self.priceStrings = newPriceStrings

                if !premiumArray.isEmpty {
                    LocalSavedPremium.save(premiumDB: .premium, premiumArray)
                    self.plans = Self.sorted(premiumArray)
                }
                completion?(self.plans)

            } catch {
                print("⚠️ Error fetching products: \(error.localizedDescription)")
                completion?(self.plans)
            }
        }
    }

    private static func sorted(_ premiums: [Premium]) -> [Premium] {
        PremiumProductId.displayOrder.compactMap { id in
            premiums.first { $0.productID == id.rawValue }
        }
    }

    /// The store's own price for a plan, or `nil` while it is still
    /// answering — the paywall falls back to `PremiumPricing` then.
    func displayPrice(for plan: PremiumPlan) -> String? {
        priceStrings[plan.productId]
    }

    // MARK: - Purchase

    func purchase(_ productId: PremiumProductId, completion: @escaping (Bool, String?) -> Void) {
        guard let product = products[productId] else {
            completion(false, LocalizedKey.premiumProductUnavailable.localized)
            return
        }

        purchaseInProgress = true
        errorMessage = nil

        Task {
            do {
                let result = try await product.purchase()
                self.purchaseInProgress = false

                switch result {
                case .success(let verification):
                    switch verification {
                    case .verified(let transaction):
                        print("✅ Purchased: \(transaction.productID)")
                        await transaction.finish()
                        self.isPremiumUnlocked = true
                        NotificationCenter.default.post(name: .iapPremiumStatusDidChange, object: nil)
                        UserDefaults.standard.set(true, forKey: String.PremiumKeys.isPurchased)
                        completion(true, nil)

                    case .unverified(_, let error):
                        print("⚠️ Transaction unverified: \(error.localizedDescription)")
                        self.errorMessage = error.localizedDescription
                        completion(false, error.localizedDescription)
                    }

                case .userCancelled:
                    print("Purchase cancelled by user")
                    completion(false, nil)

                case .pending:
                    print("Purchase pending")
                    completion(false, LocalizedKey.premiumPending.localized)

                @unknown default:
                    completion(false, LocalizedKey.premiumFailedMessage.localized)
                }

            } catch {
                self.purchaseInProgress = false
                self.errorMessage = error.localizedDescription
                print("❌ Purchase failed: \(error.localizedDescription)")
                completion(false, error.localizedDescription)
            }
        }
    }

    // MARK: - Restore Purchases

    func restorePurchases(completion: ((Bool, String?) -> Void)? = nil) {
        isRestoring = true
        Task {
            do {
                try await AppStore.sync()
                print("🔄 Restore triggered successfully")
                self.verifySubscriptions { success, message in
                    self.isRestoring = false
                    completion?(success, message)
                }
            } catch {
                self.isRestoring = false
                completion?(false, error.localizedDescription)
            }
        }
    }

    // MARK: - Verify Subscriptions

    func verifySubscriptions(completion: ((Bool, String?) -> Void)? = nil) {
        Task {
            self.isVerifying = true
            var hasActiveSubscription = false

            for await verificationResult in Transaction.currentEntitlements {
                switch verificationResult {
                case .verified(let transaction):
                    if PremiumProductId(rawValue: transaction.productID) != nil {
                        hasActiveSubscription = true
                    }
                case .unverified:
                    break
                }
            }

            if hasActiveSubscription {
                NotificationCenter.default.post(name: .iapPremiumStatusDidChange, object: nil)
            }
            self.isPremiumUnlocked = hasActiveSubscription
            UserDefaults.standard.set(hasActiveSubscription, forKey: String.PremiumKeys.isPurchased)

            completion?(hasActiveSubscription, nil)
            self.isVerifying = false
        }
    }

    func awaitVerification(timeout: TimeInterval = 4) async {
        let deadline = Date().addingTimeInterval(timeout)
        while isVerifying, Date() < deadline {
            try? await Task.sleep(nanoseconds: 50_000_000)
        }
    }

    // MARK: - Listen for Live Transactions

    private func listenForTransactions() {
        updateListenerTask = Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                switch result {
                case .verified(let transaction):
                    if PremiumProductId(rawValue: transaction.productID) != nil {
                        await transaction.finish()
                        await MainActor.run {
                            NotificationCenter.default.post(name: .iapPremiumStatusDidChange, object: nil)
                            self.isPremiumUnlocked = true
                            UserDefaults.standard.set(true, forKey: String.PremiumKeys.isPurchased)
                        }
                    }
                case .unverified:
                    break
                }
            }
        }
    }

    // MARK: - Free Tries

    static func canProceed(key: Keys = .freeTries, limit: Int = 3) -> Bool {
        guard IAPManager.shared.isPremiumUnlocked == false else { return true }
        let currentTries = KeychainManager.shared.retrieve(key: key) as? Int ?? 0
        print("🔢 \(key.rawValue) used: \(currentTries) of \(limit)")

        if currentTries >= limit {
            NotificationCenter.default.post(name: .showPremiumScreen, object: nil)
            return false
        } else {
            return true
        }
    }

    /// Spends one try.
    static func saveTrial(key: Keys = .freeTries) {
        guard IAPManager.shared.isPremiumUnlocked == false else { return }
        let currentTries = KeychainManager.shared.retrieve(key: key) as? Int ?? 0
        let newTries = currentTries + 1
        let success = KeychainManager.shared.save(key: key, value: newTries)
        print(success ? "💾 Saved \(key.rawValue). Total: \(newTries)" : "❌ Failed to save \(key.rawValue)")
    }

    static func resetAllFreeTries(key: Keys = .freeTries) {
        let success = KeychainManager.shared.delete(key: key)
        print(success ? "🧹 \(key.rawValue) reset." : "❌ Failed to reset \(key.rawValue).")
    }
}

// MARK: - Premium Keys

extension String {
    enum PremiumKeys {
        static let isPurchased = "isPurchased"
        static let freeTries = "freeTries"
    }
}
