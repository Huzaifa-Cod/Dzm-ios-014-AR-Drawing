//
//  ProfileSummary.swift
//  ARDrawing
//


import Foundation

struct ProfileSummary {
    var levelName: String
    var drawnCount: String
    var timeSpent: String
    var lessonsProgress: String

    func value(for stat: ProfileStat) -> String {
        switch stat {
        case .drawn: return drawnCount
        case .timeSpent: return timeSpent
        case .lessons: return lessonsProgress
        }
    }

    static let placeholder = ProfileSummary(
        levelName: "New Learner",
        drawnCount: "12",
        timeSpent: "0h 12m 5s",
        lessonsProgress: "1/40"
    )
}
