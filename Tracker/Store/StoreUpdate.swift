import Foundation

struct MoveItem: Hashable {
    let oldIndex: IndexPath
    let newIndex: IndexPath
}
struct MoveSection: Hashable {
    let oldIndex: Int
    let newIndex: Int
}

protocol StoreUpdateProtocol {
    var insertedItems: Set<IndexPath> { get }
    var deletedItems: Set<IndexPath> { get }
    var updatedItems: Set<IndexPath> { get }
    var movedItems: Set<MoveItem> { get }

    var insertedSections: IndexSet { get }
    var deletedSections: IndexSet { get }
    var updatedSections: IndexSet { get }
}

class StoreUpdateCollector: StoreUpdateProtocol {
    var insertedItems: Set<IndexPath> = []
    var deletedItems: Set<IndexPath> = []
    var updatedItems: Set<IndexPath> = []
    var movedItems: Set<MoveItem> = []

    var insertedSections: IndexSet = []
    var deletedSections: IndexSet = []
    var updatedSections: IndexSet = []

    func clean() {
        insertedItems = []
        deletedItems = []
        updatedItems = []
        movedItems = []

        insertedSections = []
        deletedSections = []
        updatedSections = []
    }

    func toStoreUpdate() -> StoreUpdate {
        StoreUpdate(
            insertedItems: insertedItems,
            deletedItems: deletedItems,
            updatedItems: updatedItems,
            movedItems: movedItems,

            insertedSections: insertedSections,
            deletedSections: deletedSections,
            updatedSections: updatedSections
        )
    }
}

struct StoreUpdate: StoreUpdateProtocol {
    let insertedItems: Set<IndexPath>
    let deletedItems: Set<IndexPath>
    let updatedItems: Set<IndexPath>
    let movedItems: Set<MoveItem>

    let insertedSections: IndexSet
    let deletedSections: IndexSet
    let updatedSections: IndexSet
}
