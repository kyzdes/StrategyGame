//
//  CoreDataStack.swift
//  CorporateEmpire
//
//  Core - CoreData Stack
//

import Foundation
import CoreData

protocol CoreDataStack {
    var viewContext: NSManagedObjectContext { get }
    var backgroundContext: NSManagedObjectContext { get }
    func saveContext() throws
}

final class DefaultCoreDataStack: CoreDataStack {
    static let shared = DefaultCoreDataStack()

    private let modelName: String = "CorporateEmpire"

    // MARK: - Core Data Stack

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        return container
    }()

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    var backgroundContext: NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }

    // MARK: - Core Data Saving

    func saveContext() throws {
        let context = viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                throw CoreDataError.saveFailed(error)
            }
        }
    }

    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }

    // MARK: - Entity Management

    func fetch<T: NSManagedObject>(_ request: NSFetchRequest<T>) throws -> [T] {
        do {
            return try viewContext.fetch(request)
        } catch {
            throw CoreDataError.fetchFailed(error)
        }
    }

    func delete(_ object: NSManagedObject) throws {
        viewContext.delete(object)
        try saveContext()
    }

    func deleteAll<T: NSManagedObject>(ofType type: T.Type) throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: type))
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try viewContext.execute(deleteRequest)
            try saveContext()
        } catch {
            throw CoreDataError.deleteFailed(error)
        }
    }
}

// MARK: - Core Data Errors

enum CoreDataError: LocalizedError {
    case saveFailed(Error)
    case fetchFailed(Error)
    case deleteFailed(Error)
    case invalidObject

    var errorDescription: String? {
        switch self {
        case .saveFailed(let error):
            return "Failed to save: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Failed to fetch: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete: \(error.localizedDescription)"
        case .invalidObject:
            return "Invalid managed object"
        }
    }
}

// MARK: - NSManagedObject Extensions

extension NSManagedObject {
    static var entityName: String {
        return String(describing: self)
    }

    static func fetchRequest<T: NSManagedObject>() -> NSFetchRequest<T> {
        return NSFetchRequest<T>(entityName: entityName)
    }
}
