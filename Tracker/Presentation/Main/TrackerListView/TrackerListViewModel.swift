import UIKit

struct TrackerListViewModel {
    var numberOfCategories: Int { categories.count }
    
    private var categories = [TrackerCategory]()
    private var groupedTrackers = [TrackerCategory: [Tracker]]()

    init(trackers: [Tracker]) {
        categories = []
        groupedTrackers = [:]
        
        categories = Array(Set(trackers.map({ tracker in tracker.category })))
        for tracker in trackers {
            if groupedTrackers[tracker.category] != nil {
                groupedTrackers[tracker.category]?.append(tracker)
            } else {
                groupedTrackers[tracker.category] = [tracker]
            }
        }
    }

    func numberOfTrackersInCategory(byIndex index: Int) -> Int {
        let category = categories[index]
        return groupedTrackers[category]?.count ?? 0
    }
    func categoryName(byIndex index: Int) -> String { categories[index].name }
    func tracker(byIndexPath indexPath: IndexPath) -> Tracker {
        let category = categories[indexPath.section]
        let tracker = groupedTrackers[category]![indexPath.row]
        return tracker
    }
}
