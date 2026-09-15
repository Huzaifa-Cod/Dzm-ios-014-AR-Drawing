//
//  KeychainManager.swift
//  ARDrawing
//
//  Ported from the Language Learning project unchanged, so the free-tries
//  behaviour matches across the apps.
//
//  Note the name is historical: this is backed by `UserDefaults`, not the
//  keychain. That is how it works in the other apps too, and it is kept
//  that way deliberately so the behaviour stays identical — worth knowing
//  that free tries therefore reset when the app is deleted.
//

import Foundation

enum Keys: String {
    case freeTries
}

final class KeychainManager {

    static let shared = KeychainManager()

    private let userDefaults = UserDefaults.standard

    private init() {}

    func save(key: Keys, value: Any) -> Bool {
        userDefaults.set(value, forKey: key.rawValue)
        return true
    }

    func retrieve(key: Keys) -> Any? {
        userDefaults.object(forKey: key.rawValue)
    }

    func update(key: Keys, value: Any) -> Bool {
        userDefaults.set(value, forKey: key.rawValue)
        return true
    }

    func delete(key: Keys) -> Bool {
        userDefaults.removeObject(forKey: key.rawValue)
        return true
    }
}
