//
//  LocalizationManager.swift
//  ARDrawing
//
//  Owns the app's current display language: seeds `Bundle.main`'s
//  override on launch from whatever was last persisted, and re-points
//  it whenever the user picks a new one in Settings. `RootView` keys
//  its whole hierarchy off `language`, so every screen — including
//  ones already on the navigation stack — rebuilds with the new
//  strings the instant it changes, no app restart needed.
//

import Combine
import Foundation

@MainActor
final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @Published private(set) var language: AppLanguage

    private init() {
        let current = UserDefaultsManager.shared.selectedLanguage
        language = current
        Bundle.setLanguage(current)
    }

    func setLanguage(_ language: AppLanguage) {
        guard language != self.language else { return }
        Bundle.setLanguage(language)
        UserDefaultsManager.shared.selectedLanguage = language
        self.language = language
    }
}
