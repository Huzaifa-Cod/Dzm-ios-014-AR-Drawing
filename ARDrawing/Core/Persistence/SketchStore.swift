//
//  SketchStore.swift
//  ARDrawing

import CoreData
import UIKit

/// Which album tab a saved item belongs to.
enum SketchKind: String {
    case drawn
    case recorded
}

/// Core Data reads/writes for finished sketches. The Album and Profile
/// screens use `@FetchRequest` directly; this covers the writes and the
/// single-item lookup the result screen needs.
enum SketchStore {
    private static let logTag = "[SketchStore]"

    @discardableResult
    static func save(
        image: UIImage,
        kind: SketchKind = .drawn,
        in context: NSManagedObjectContext
    ) -> UUID? {
        guard let data = image.pngData() else {
            print("\(logTag) Couldn't encode the sketch as PNG — nothing saved.")
            return nil
        }

        let id = UUID()
        let sketch = SavedSketch(context: context)
        sketch.id = id
        sketch.createdAt = Date()
        sketch.imageData = data
        sketch.kind = kind.rawValue

        do {
            try context.save()
            return id
        } catch {
            print("\(logTag) Save failed: \(error.localizedDescription)")
            context.rollback()
            return nil
        }
    }

    static func sketch(with id: UUID, in context: NSManagedObjectContext) -> SavedSketch? {
        let request = NSFetchRequest<SavedSketch>(entityName: "SavedSketch")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        do {
            return try context.fetch(request).first
        } catch {
            print("\(logTag) Lookup failed: \(error.localizedDescription)")
            return nil
        }
    }

    static func delete(_ sketches: [SavedSketch], in context: NSManagedObjectContext) {
        guard !sketches.isEmpty else { return }
        sketches.forEach(context.delete)
        do {
            try context.save()
        } catch {
            print("\(logTag) Delete failed: \(error.localizedDescription)")
            context.rollback()
        }
    }
}

extension SavedSketch {
    var uiImage: UIImage? {
        guard let imageData else { return nil }
        return UIImage(data: imageData)
    }
}
