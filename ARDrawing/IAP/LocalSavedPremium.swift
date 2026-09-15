//
//  LocalSavedPremium.swift
//  ARDrawing
//
//  Caches the plans StoreKit last returned, so the paywall can show real
//  prices immediately instead of empty cards while the store answers.
//

import Foundation

struct LocalSavedPremium {

    enum PremiumDB: String {
        case premium = "premium"
        case premium2 = "premium2"
        case offer = "offer"
    }

    static func get(premiumDB: PremiumDB, complition: @escaping ([Premium]) -> Void) {
        let defaults = UserDefaults.standard
        guard let data = defaults.data(forKey: premiumDB.rawValue) else {
            complition([])
            return
        }
        do {
            let array = try PropertyListDecoder().decode([Premium].self, from: data)
            complition(array)
        } catch {
            print("⚠️ LocalSavedPremium decode failed, clearing cache: \(error)")
            defaults.removeObject(forKey: premiumDB.rawValue)
            complition([])
        }
    }

    static func save(premiumDB: PremiumDB, _ premium: [Premium]) {
        if let data = try? PropertyListEncoder().encode(premium) {
            UserDefaults.standard.set(data, forKey: premiumDB.rawValue)
        }
    }
}
