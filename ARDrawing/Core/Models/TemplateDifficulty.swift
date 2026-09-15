//
//  TemplateDifficulty.swift
//  ARDrawing
//
//  `Sketches.json` carries no difficulty or duration for a template, so
//  this derives both deterministically from where a template sits in
//  its category — same index in, same result out, nothing to keep in
//  sync with the catalog.
//

import Foundation

enum TemplateDifficulty: Int, CaseIterable {
    case easy
    case medium
    case expert

    var titleKey: LocalizedKey {
        switch self {
        case .easy: return .templateDifficultyEasy
        case .medium: return .templateDifficultyMedium
        case .expert: return .templateDifficultyExpert
        }
    }

    /// Rough time to finish a template at this difficulty.
    var averageMinutes: Int {
        switch self {
        case .easy: return 10
        case .medium: return 20
        case .expert: return 35
        }
    }

    /// The harder a template, the more likely someone reaches for a
    /// shortcut instead of drawing it freehand — so Expert is the one
    /// tier gated behind Pro.
    var requiresPro: Bool { self == .expert }
}

enum TemplateDifficultyRules {
    static func difficulty(forIndex index: Int) -> TemplateDifficulty {
        let cases = TemplateDifficulty.allCases
        return cases[(index - 1) % cases.count]
    }
}
