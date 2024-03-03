import Foundation
import CoreData

protocol StoreDelegate: AnyObject {
    func store(didUpdate update: StoreUpdate)
}

struct Move: Hashable {
    let oldIndex: Int
    let newIndex: Int
}

protocol StoreUpdateProtocol {
    var insertedIndexes: IndexSet { get }
    var deletedIndexes: IndexSet { get }
    var updatedIndexes: IndexSet { get }
    var movedIndexes: Set<Move> { get }
}

class StoreUpdateCollector: StoreUpdateProtocol {
    var insertedIndexes: IndexSet = []
    var deletedIndexes: IndexSet = []
    var updatedIndexes: IndexSet = []
    var movedIndexes: Set<Move> = []

    func clean() {
        insertedIndexes = []
        deletedIndexes = []
        updatedIndexes = []
        movedIndexes = []
    }

    func toStoreUpdate() -> StoreUpdate {
        StoreUpdate(
            insertedIndexes: insertedIndexes,
            deletedIndexes: deletedIndexes,
            updatedIndexes: updatedIndexes,
            movedIndexes: movedIndexes
        )
    }
}

struct StoreUpdate: StoreUpdateProtocol {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

protocol CDObject: NSManagedObject {
    associatedtype StorableObject: CDStorableObject
    func toEntity() -> StorableObject?
}

protocol CDStorableObject {
    associatedtype StoredObject: CDObject
    func toCD(context: NSManagedObjectContext) -> StoredObject
}

class BaseCDStore<StoredObject: CDObject>: NSObject, NSFetchedResultsControllerDelegate {
    weak var delegate: StoreDelegate?

    let cdContext: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<StoredObject>?
    private var update = StoreUpdateCollector()

    private var objects: [StoredObject.StorableObject] {
        guard let ctl = fetchedResultsController, let objects = ctl.fetchedObjects else { return [] }
        return objects.map { $0.toEntity() }.compactMap { $0 }
    }

    init(cdContext: NSManagedObjectContext) {
        self.cdContext = cdContext

        super.init()
    }

    func fetchData(controller: NSFetchedResultsController<StoredObject>) throws {
        controller.delegate = self
        try controller.performFetch()

        self.fetchedResultsController = controller
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        objects.count
    }

    func object(atIndexPath: IndexPath) -> StoredObject.StorableObject? {
        objects[atIndexPath.row]
    }

    func add(_ record: StoredObject.StorableObject) {
        _ = record.toCD(context: cdContext)
        save()
    }
    func delete(at indexPath: IndexPath) {
        guard let fetchedResultsController else { return }
        let record = fetchedResultsController.object(at: indexPath)
        cdContext.delete(record)
        save()
    }
    func update(at indexPath: IndexPath) {}

    private func save() {
        if cdContext.hasChanges {
            do {
                try cdContext.save()
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        update.clean()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let delegate else { return }
        delegate.store(didUpdate: update.toStoreUpdate())
        update.clean()
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { return }
            update.insertedIndexes.insert(indexPath.item)
        case .delete:
            guard let indexPath else { return }
            update.deletedIndexes.insert(indexPath.item)
        case .update:
            guard let indexPath else { return }
            update.updatedIndexes.insert(indexPath.item)
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath else { return }
            update.movedIndexes.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
        @unknown default:
            return
        }
    }
}
