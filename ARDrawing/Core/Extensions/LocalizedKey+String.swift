//
//  LocalizedKey+String.swift
//  ARDrawing
//

import Foundation

extension LocalizedKey {
    var localized: String {
        NSLocalizedString(rawValue, comment: "")
    }
}
