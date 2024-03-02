import Foundation

protocol StoreDelegate: AnyObject {
    func store(didUpdate update: StoreUpdate)
}

protocol Store {
    var delegate: StoreDelegate? { get set }

    func fetchData() throws
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(atIndexPath: IndexPath) -> TrackerCategory?
    func add(_ record: TrackerCategory)
    func delete(at indexPath: IndexPath)
    func update(at indexPath: IndexPath)
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
