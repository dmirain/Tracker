import UIKit

final class TrackerListViewModel {
    var numberOfCategories: Int { listCategories.count }
    
    private var listCategories: [CategoryWithTrackers] = []

    init(trackers: [Tracker]) {
        updateTrackers(trackers: trackers)
    }
    
    func updateTrackers(trackers: [Tracker]) {
        listCategories = Dictionary(grouping: trackers, by: { $0.category })
            .map { (key: TrackerCategory, value: [Tracker]) in
                CategoryWithTrackers(category: key, trackers: value)
            }
    }

    func numberOfTrackersInCategory(byIndex index: Int) -> Int {
        listCategories[index].trackers.count
    }
    func categoryName(byIndex index: Int) -> String {
        listCategories[index].category.name
    }
    func tracker(byIndexPath indexPath: IndexPath) -> Tracker {
        listCategories[indexPath.section].trackers[indexPath.row]
    }
}
