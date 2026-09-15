//
//  Bundle+Language.swift
//  ARDrawing
//
//  `NSLocalizedString` (what `LocalizedKey.localized` calls) always
//  reads from `Bundle.main`, and `Bundle.main` always resolves strings
//  using the device's own language — there's no built-in way to make
//  it use a language the user picked inside the app instead. This
//  swaps `Bundle.main`'s class for one that redirects every lookup to
//  a specific `.lproj` bundle, the standard workaround for an in-app
//  language switch that doesn't touch the device's system language.
//

import Foundation

private var associatedBundleKey: UInt8 = 0

private final class LanguageOverrideBundle: Bundle, @unchecked Sendable {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard
            let bundle = objc_getAssociatedObject(self, &associatedBundleKey) as? Bundle
        else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {
    /// Points every `NSLocalizedString` lookup at `language`'s `.lproj`
    /// bundle from here on. Safe to call repeatedly — swapping the
    /// class again is a no-op once it's already the override class.
    static func setLanguage(_ language: AppLanguage) {
        guard
            let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
            let languageBundle = Bundle(path: path)
        else { return }

        if object_getClass(Bundle.main) != LanguageOverrideBundle.self {
            object_setClass(Bundle.main, LanguageOverrideBundle.self)
        }
        objc_setAssociatedObject(Bundle.main, &associatedBundleKey, languageBundle, .OBJC_ASSOCIATION_RETAIN)
    }
}
