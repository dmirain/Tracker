import Foundation
import CoreData

protocol StoreDelegate: AnyObject {
    func store(didUpdate update: StoreUpdate)
}

protocol CDObject: NSManagedObject {
    associatedtype StorableObject: CDStorableObject
    func toEntity() -> StorableObject?
    func update(by: StorableObject)
}

protocol CDStorableObject: Identifiable {
    associatedtype StoredObject: CDObject
    func toCD(context: NSManagedObjectContext) -> StoredObject
}

class BaseCDStore<StoredObject: CDObject>: NSObject, NSFetchedResultsControllerDelegate {
    weak var delegate: StoreDelegate?

    let cdContext: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<StoredObject>?
    private var update = StoreUpdateCollector()

    var numberOfSections: Int {
        fetchedResultsController?.sections?.count ?? 0
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
        fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }

    func sectionName(_ section: Int) -> String {
        fetchedResultsController?.sections?[section].name ?? ""
    }

    func object(atIndexPath: IndexPath) -> StoredObject.StorableObject? {
        cdObject(atIndexPath: atIndexPath)?.toEntity()
    }

    func cdObject(atIndexPath: IndexPath) -> StoredObject? {
        fetchedResultsController?.object(at: atIndexPath)
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
    func update(record newState: StoredObject.StorableObject) {
        let request = StoredObject.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", argumentArray: [newState.id])
        guard
            let record = (try? cdContext.fetch(request))?.first,
            let record = record as? StoredObject
        else { return }

        record.update(by: newState)
        save()
    }

    func save() {
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
            update.insertedItems.insert(indexPath)
        case .delete:
            guard let indexPath else { return }
            update.deletedItems.insert(indexPath)
        case .update:
            guard let indexPath else { return }
            update.updatedItems.insert(indexPath)
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath else { return }
            update.movedItems.insert(.init(oldIndex: oldIndexPath, newIndex: newIndexPath))
        @unknown default:
            return
        }
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType
    ) {
        switch type {
        case .insert:
            update.insertedSections.insert(sectionIndex)
        case .delete:
            update.deletedSections.insert(sectionIndex)
        case .update:
            update.updatedSections.insert(sectionIndex)
        case .move:
            return
        @unknown default:
            return
        }
    }
}
