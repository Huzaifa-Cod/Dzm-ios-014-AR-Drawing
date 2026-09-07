//
//  LocalizedKey+String.swift
//  ARDrawing
//
//  Thin wrapper around NSLocalizedString / Localizable.strings.
//  Always add UI copy through `LocalizedKey` in AppEnums.swift
//  instead of typing raw strings in Views.
//

import Foundation

extension LocalizedKey {
    var localized: String {
        NSLocalizedString(rawValue, comment: "")
    }
}
