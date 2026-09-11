//
//  ARDrawingApp.swift
//  ARDrawing
//
//  Created by Mac mini m4 on 07/09/2026.
//

import SwiftUI
import CoreData
import Firebase

@main
struct ARDrawingApp: App {
    // Without this, `AppDelegate.application(_:didFinishLaunchingWithOptions:)`
    // never fires and `FirebaseApp.configure()` never runs — every
    // Firebase call (Storage included) would crash on first use.
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}


/// UIKit-style delegate, bridged in for the SDKs that need a launch hook.
final class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        setupFirebase()
        return true
    }

    /// The design is portrait-only.
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        .portrait
    }
    
    func setupFirebase() {
        guard let dataAsset = NSDataAsset(name: "FBP") else {
            fatalError("Failed to load GoogleService-Info from Assets")
        }

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("FBP.plist")
        do {
            try dataAsset.data.write(to: tempURL)
            guard let options = FirebaseOptions(contentsOfFile: tempURL.path) else {
                fatalError("Failed to create FirebaseOptions from data asset")
            }
            FirebaseApp.configure(options: options)
        } catch {
            fatalError("Error writing plist data to temp file: \(error)")
        }
    }
}



