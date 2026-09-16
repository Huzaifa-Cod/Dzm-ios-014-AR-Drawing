//
//  TutorialVideoCatalogStore.swift
//  ARDrawing


import Combine
import FirebaseStorage
import Foundation

private struct TutorialVideoManifest: Codable {
    let videos: [String]
}

@MainActor
final class TutorialVideoCatalogStore: ObservableObject {
    
    @Published private(set) var resolvedURLs: [DrawMode: URL] = [:]

    private static let logTag = "[TutorialVideoCatalogStore]"
    private static let jsonPath = "SketchVideo.json"
    private static let cacheKey = "cachedSketchVideoJSON"
    /// Tried in order for each matched filename — "videos/" mirrors how
    /// template images live under "templates/", tried first; the bare
    /// root name is the fallback if a clip was uploaded loose instead.
    private static let candidateFolders = ["videos", ""]
    private static let resolvedURLCacheKey = "cachedTutorialVideoURLs"

    private let storage = Storage.storage()
    private var didStartLoading = false

    private lazy var urlCache: [String: URL] = {
        guard let dict = UserDefaults.standard.dictionary(forKey: Self.resolvedURLCacheKey) as? [String: String] else {
            return [:]
        }
        return dict.compactMapValues(URL.init(string:))
    }()

    func loadIfNeeded() {
        guard !didStartLoading else { return }
        didStartLoading = true

        if let data = UserDefaults.standard.data(forKey: Self.cacheKey) {
            apply(names: decode(data, source: "UserDefaults cache"))
        }

        Task {
            await FirebaseAppAuth.shared.ensureSignedIn()

            let ref = storage.reference().child(Self.jsonPath)
            print("\(Self.logTag) Fetching \(Self.jsonPath) from Firebase Storage…")

            ref.getData(maxSize: 1 * 1024 * 1024) { [weak self] data, error in
                Task { @MainActor in
                    guard let self else { return }

                    if let error {
                        print("\(Self.logTag) Fetching \(Self.jsonPath) failed: \(error.localizedDescription)")
                        return
                    }
                    guard let data else {
                        print("\(Self.logTag) Fetch returned no data.")
                        return
                    }

                    UserDefaults.standard.set(data, forKey: Self.cacheKey)
                    self.apply(names: self.decode(data, source: "network"))
                }
            }
        }
    }

    private func decode(_ data: Data, source: String) -> [String] {
        do {
            let manifest = try JSONDecoder().decode(TutorialVideoManifest.self, from: data)
            print("\(Self.logTag) Loaded \(manifest.videos.count) clip(s) from \(source): \(manifest.videos.joined(separator: ", "))")
            return manifest.videos
        } catch {
            print("\(Self.logTag) Decoding failed (\(source)): \(error)")
            return []
        }
    }

    /// Matches every mode against the manifest and kicks off resolution
    /// for whichever ones changed, so a re-fetch that returns the same
    /// list doesn't re-hit Storage for URLs it already has.
    private func apply(names: [String]) {
        for mode in DrawMode.allCases {
            guard resolvedURLs[mode] == nil, let name = matchedName(for: mode, in: names) else { continue }
            Task { await resolve(mode: mode, name: name) }
        }
    }

    private func matchedName(for mode: DrawMode, in names: [String]) -> String? {
        names.first { name in
            let lowered = name.lowercased()
            return mode.tutorialVideoKeywords.contains { lowered.contains($0) }
        }
    }

    /// Resolves one clip's download URL, trying each candidate folder in
    /// turn — the same self-healing shape `TemplateCatalogStore` uses for
    /// image extensions, applied here to folder layout instead.
    private func resolve(mode: DrawMode, name: String) async {
        if let cached = urlCache[name] {
            resolvedURLs[mode] = cached
            return
        }

        for folder in Self.candidateFolders {
            let path = folder.isEmpty ? "\(name).mp4" : "\(folder)/\(name).mp4"
            do {
                let url = try await storage.reference().child(path).downloadURL()
                urlCache[name] = url
                persistURLCache()
                resolvedURLs[mode] = url
                return
            } catch {
                let nsError = error as NSError
                if let code = StorageErrorCode(rawValue: nsError.code), code == .objectNotFound {
                    continue
                }
                print("\(Self.logTag) Resolving \(path) failed: \(error.localizedDescription)")
                return
            }
        }
        print("\(Self.logTag) No file found for \(name) under any of \(Self.candidateFolders) — check it was uploaded as .mp4.")
    }

    private func persistURLCache() {
        UserDefaults.standard.set(urlCache.mapValues(\.absoluteString), forKey: Self.resolvedURLCacheKey)
    }
}
