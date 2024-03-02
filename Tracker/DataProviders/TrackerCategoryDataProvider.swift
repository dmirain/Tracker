import Foundation
import CoreData

protocol DataProviderDelegate: AnyObject {
    func dataProvider(didUpdate update: DataProviderUpdate)
}

protocol TrackerCategoryDataProvider {
    var delegate: DataProviderDelegate? { get set }

    func fetchData() throws
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(atIndexPath: IndexPath) -> TrackerCategory?
    func add(_ record: TrackerCategory)
    func delete(at indexPath: IndexPath)
    func update(at indexPath: IndexPath)
}

class DataProviderUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
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
}

final class TrackerCategoryDataProviderCD: NSObject, TrackerCategoryDataProvider {
    weak var delegate: DataProviderDelegate?

    private let cdContext: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCD>
    private var update = DataProviderUpdate()

    private var categories: [TrackerCategory] {
        guard let objects = self.fetchedResultsController.fetchedObjects else { return [] }
        return objects.map { $0.toEntity() }.compactMap { $0 }
    }

    init(cdContext: NSManagedObjectContext) {
        self.cdContext = cdContext

        let fetchRequest = TrackerCategoryCD.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCD.name, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: cdContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        self.fetchedResultsController = controller

        super.init()
        controller.delegate = self
    }

    func fetchData() throws {
        try fetchedResultsController.performFetch()
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        categories.count
    }

    func object(atIndexPath: IndexPath) -> TrackerCategory? {
        categories[atIndexPath.row]
    }

    func add(_ record: TrackerCategory) {
        _ = record.toCD(context: cdContext)
        save()
    }
    func delete(at indexPath: IndexPath) {
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
}

extension TrackerCategoryDataProviderCD: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        update.clean()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.dataProvider(didUpdate: update)
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        print("has update")

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

fileprivate extension TrackerCategory {
    func toCD(context: NSManagedObjectContext) -> TrackerCategoryCD {
        let cdCategory = TrackerCategoryCD(context: context)
        cdCategory.name = name
        return cdCategory
    }
}

fileprivate extension TrackerCategoryCD {
    func toEntity() -> TrackerCategory? {
        guard let name else { return nil }
        return TrackerCategory(name: name)
    }
}
