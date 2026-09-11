//
//  TemplateCatalogStore.swift
//  ARDrawing

import Combine
import FirebaseAuth
import FirebaseStorage
import Foundation

/// One category block from Sketches.json.
struct TemplateCategoryData: Codable, Identifiable, Hashable {
    let folderName: String
    let categoryName: String
    let imagePrefix: String
    let imageCount: Int

    var id: String { folderName }
}

private struct TemplateCatalogResponse: Codable {
    let categories: [TemplateCategoryData]
}

@MainActor
final class TemplateCatalogStore: ObservableObject {
    @Published private(set) var categories: [TemplateCategoryData] = []
    @Published private(set) var isLoading = false
    @Published private(set) var lastError: String?

    private static let logTag = "[TemplateCatalogStore]"
    private static let cacheKey = "cachedTemplateCatalogJSON"
    private static let jsonPath = "Sketches.json"
    private static let templatesFolder = "templates"
    /// Sketches.json doesn't carry a per-image file extension, and the
    /// upload turned out inconsistent — most categories are `.jpg`,
    /// `superheroes` is `.png`. Each image tries these in order until
    /// one actually exists.
    private static let candidateExtensions = ["jpg", "png"]

    private let storage = Storage.storage()
    private var didStartLoading = false

    private var signInTask: Task<Void, Never>?

    private static let resolvedURLCacheKey = "cachedTemplateImageURLs"
    private lazy var resolvedURLCache: [String: URL] = {
        guard let dict = UserDefaults.standard.dictionary(forKey: Self.resolvedURLCacheKey) as? [String: String] else {
            return [:]
        }
        return dict.compactMapValues(URL.init(string:))
    }()

    /// Called once from wherever first needs the catalog (Home, on
    /// appear). Later calls are no-ops so Home and Templates sharing
    /// this instance don't trigger duplicate fetches.
    func loadIfNeeded() {
        guard !didStartLoading else { return }
        didStartLoading = true
        loadFromCache(reason: "shown immediately while the network fetch runs")
        refresh()
    }

    func refresh() {
        isLoading = true
        lastError = nil

        Task {
            await ensureSignedIn()

            let path = Self.jsonPath
            let ref = storage.reference().child(path)
            print("\(Self.logTag) Fetching \(path) from Firebase Storage… (bucket=\(ref.bucket), fullPath=\(ref.fullPath))")

            ref.getData(maxSize: 5 * 1024 * 1024) { [weak self] data, error in
                Task { @MainActor in
                    guard let self else { return }
                    self.isLoading = false

                    if let error {
                        self.logStorageError(error, context: "Fetching \(path)")
                        self.lastError = error.localizedDescription
                        self.loadFromCache(reason: "network fetch failed")
                        return
                    }
                    guard let data else {
                        print("\(Self.logTag) Fetch returned no data.")
                        self.lastError = "No data returned"
                        self.loadFromCache(reason: "network fetch returned nothing")
                        return
                    }

                    if self.apply(data: data, source: "network") {
                        UserDefaults.standard.set(data, forKey: Self.cacheKey)
                    }
                }
            }
        }
    }

    /// Signs in anonymously if there's no session yet. Storage's rules
    /// reject unauthenticated requests outright, so every Storage call
    /// in this store routes through this first.
    private func ensureSignedIn() async {
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

    private func loadFromCache(reason: String) {
        // Already showing cached data from the head start at launch —
        // no need to decode it a second time just because the network
        // fetch that was racing it also failed.
        guard categories.isEmpty else { return }
        guard let data = UserDefaults.standard.data(forKey: Self.cacheKey) else {
            print("\(Self.logTag) No cached catalog available (\(reason)) — templates will be empty until the network fetch succeeds.")
            return
        }
        _ = apply(data: data, source: "UserDefaults cache (\(reason))")
    }

    @discardableResult
    private func apply(data: Data, source: String) -> Bool {
        do {
            let response = try JSONDecoder().decode(TemplateCatalogResponse.self, from: data)
            categories = response.categories
            let names = response.categories.map(\.categoryName).joined(separator: ", ")
            print("\(Self.logTag) Loaded \(response.categories.count) categories from \(source): \(names)")
            return true
        } catch {
            print("\(Self.logTag) Decoding failed (\(source)): \(error)")
            lastError = "Couldn't read the template catalog"
            return false
        }
    }

    /// Synchronous cache lookup — checked first, so a `TemplateThumbnailView`
    /// that's already resolved once can seed its state before its
    /// `.task` even starts, instead of flashing a spinner it doesn't need.
    func cachedImageURL(category: TemplateCategoryData, index: Int) -> URL? {
        resolvedURLCache[cacheKey(category: category, index: index)]
    }

    /// Resolves the real download URL for one image, trying each
    /// candidate extension in turn until Storage confirms one exists.
    /// Logs every attempt so a genuinely missing image (wrong index,
    /// typo'd prefix, not uploaded yet) is easy to spot in the console.
    /// Caches the result — see `resolvedURLCache`.
    func resolveImageURL(category: TemplateCategoryData, index: Int) async -> URL? {
        let key = cacheKey(category: category, index: index)
        if let cached = resolvedURLCache[key] {
            return cached
        }

        await ensureSignedIn()

        let basePath = "\(Self.templatesFolder)/\(category.folderName)/\(category.imagePrefix)\(String(format: "%03d", index))"
        for ext in Self.candidateExtensions {
            let path = "\(basePath).\(ext)"
            do {
                let url = try await storage.reference().child(path).downloadURL()
                cache(url, forKey: key)
                return url
            } catch {
                let nsError = error as NSError
                if let code = StorageErrorCode(rawValue: nsError.code), code == .objectNotFound {
                    // Expected for every extension except the right one —
                    // not worth logging on its own.
                    continue
                }
                logStorageError(error, context: "Resolving \(path)")
                return nil
            }
        }
        print("\(Self.logTag) No file found for \(basePath) with any of \(Self.candidateExtensions) — check the index/prefix against Storage.")
        return nil
    }

    /// Drops one image's cached URL so the next resolve re-asks
    /// Storage — the self-healing side of caching: if a token ever
    /// does go bad, `TemplateThumbnailView` calls this on load failure
    /// and retries once, rather than being stuck on a dead URL forever.
    func invalidateResolvedURL(category: TemplateCategoryData, index: Int) {
        resolvedURLCache.removeValue(forKey: cacheKey(category: category, index: index))
        persistResolvedURLCache()
    }

    private func cacheKey(category: TemplateCategoryData, index: Int) -> String {
        "\(category.folderName)/\(category.imagePrefix)\(String(format: "%03d", index))"
    }

    private func cache(_ url: URL, forKey key: String) {
        resolvedURLCache[key] = url
        persistResolvedURLCache()
    }

    private func persistResolvedURLCache() {
        UserDefaults.standard.set(
            resolvedURLCache.mapValues(\.absoluteString),
            forKey: Self.resolvedURLCacheKey
        )
    }

    private func logStorageError(_ error: Error, context: String) {
        let nsError = error as NSError
        print("\(Self.logTag) \(context) failed: \(error.localizedDescription)")
        print("\(Self.logTag)   domain=\(nsError.domain) code=\(nsError.code)")
        if let storageErrorCode = StorageErrorCode(rawValue: nsError.code) {
            print("\(Self.logTag)   StorageErrorCode=\(storageErrorCode)")
        }
    }
}
