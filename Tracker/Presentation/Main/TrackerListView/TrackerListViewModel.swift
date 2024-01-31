import UIKit

final class TrackerListViewModel {

    var selectedDate: DateWoTime
    var searchQuery: String?

    var numberOfCategories: Int { listCategories.count }

    private var listCategories: [CategoryWithTrackers] = []
    private var completedTrackers: [UUID: [TrackerRecord]] = [:]

    init(selectedDate: DateWoTime, searchQuery: String?) {
        self.selectedDate = selectedDate
        self.searchQuery = searchQuery
    }

    func updateTrackersData(trackers: [Tracker], completedTrackers: [TrackerRecord]) {
        listCategories = Dictionary(grouping: trackers, by: { $0.category })
            .map { (key: TrackerCategory, value: [Tracker]) in
                CategoryWithTrackers(category: key, trackers: value.sorted { $0.name > $1.name })
            }
            .sorted { $0.category.name > $1.category.name }

        self.completedTrackers = Dictionary(grouping: completedTrackers, by: { $0.trackerId })
    }

    func numberOfTrackersInCategory(byIndex index: Int) -> Int {
        listCategories[index].trackers.count
    }
    func categoryName(byIndex index: Int) -> String {
        listCategories[index].category.name
    }
    func tracker(byIndexPath indexPath: IndexPath) -> TrackerViewModel {
        let tracker = listCategories[indexPath.section].trackers[indexPath.row]
        return TrackerViewModel(
            tracker: tracker,
            complitionsCount: complitionsCount(byTracker: tracker),
            isComplited: isComplited(tracker: tracker, on: selectedDate),
            selectedDate: selectedDate
        )
    }

    private func complitionsCount(byTracker tracker: Tracker) -> Int {
        completedTrackers[tracker.id]?.count ?? 0
    }

    private func isComplited(tracker: Tracker, on date: DateWoTime) -> Bool {
        completedTrackers[tracker.id]?.contains(where: { $0.date == date }) ?? false
    }
}

struct TrackerViewModel {
    let tracker: Tracker
    let complitionsCount: Int
    let isComplited: Bool
    let selectedDate: DateWoTime
}
