import Foundation
import CoreData

protocol TrackerCategoryStore {
    var delegate: StoreDelegate? { get set }

    func fetchData() throws
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(atIndexPath: IndexPath) -> TrackerCategory?
    func add(_ record: TrackerCategory)
    func delete(at indexPath: IndexPath)
    func update(at indexPath: IndexPath)
}

final class TrackerCategoryStoreCD: BaseCDStore<TrackerCategoryCD>, TrackerCategoryStore {
    func fetchData() throws {
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
        try super.fetchData(controller: controller)
    }
}

extension TrackerCategory: CDStorableObject {
    func toCD(context: NSManagedObjectContext) -> TrackerCategoryCD {
        let cdCategory = TrackerCategoryCD(context: context)
        cdCategory.id = id
        cdCategory.name = name
        return cdCategory
    }
}

extension TrackerCategoryCD: CDObject {
    func toEntity() -> TrackerCategory? {
        guard let name, let id else { return nil }
        return TrackerCategory(
            id: id,
            name: name
        )
    }
}
