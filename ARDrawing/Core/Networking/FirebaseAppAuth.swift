//
//  FirebaseAppAuth.swift
//  ARDrawing
//
//  Anonymous sign-in, shared by every store that reads from Firebase
//  Storage. Storage's rules reject unauthenticated requests outright, so
//  every Storage call in the app routes through `ensureSignedIn()` first.
//
//  Pulled out of `TemplateCatalogStore` once a second store needed the same
//  thing — without a shared owner, two stores racing on launch would each
//  kick off their own `signInAnonymously()` call.
//

import FirebaseAuth
import Foundation

@MainActor
final class FirebaseAppAuth {
    static let shared = FirebaseAppAuth()

    private static let logTag = "[FirebaseAppAuth]"

    private var signInTask: Task<Void, Never>?

    private init() {}

    func ensureSignedIn() async {
        if let task = signInTask {
            await task.value
            return
        }
        if Auth.auth().currentUser != nil {
            return
        }

        let task = Task<Void, Never> {
            print("\(Self.logTag) No auth session — signing in anonymously…")
            do {
                let result = try await Auth.auth().signInAnonymously()
                print("\(Self.logTag) Signed in anonymously (uid=\(result.user.uid))")
            } catch {
                print("\(Self.logTag) Anonymous sign-in failed: \(error.localizedDescription) — Storage calls will likely be rejected. Check that Anonymous sign-in is enabled under Firebase Console → Authentication → Sign-in method.")
            }
        }
        signInTask = task
        await task.value
    }
}
