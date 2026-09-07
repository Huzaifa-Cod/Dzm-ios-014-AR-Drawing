//
//  ARDrawingApp.swift
//  ARDrawing
//
//  Created by Mac mini m4 on 07/09/2026.
//

import SwiftUI
import CoreData

@main
struct ARDrawingApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
