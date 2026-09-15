//
//  LocalizedKey+String.swift
//  ARDrawing
//

import Foundation

extension LocalizedKey {
    var localized: String {
        NSLocalizedString(rawValue, comment: "")
    }

    /// For copy that carries a value the app supplies — a store price, a
    /// count. Keeps the sentence in Localizable.strings, where a translator
    /// can move the placeholder to wherever their language needs it.
    func localized(_ arguments: CVarArg...) -> String {
        String(format: localized, arguments: arguments)
    }
}
