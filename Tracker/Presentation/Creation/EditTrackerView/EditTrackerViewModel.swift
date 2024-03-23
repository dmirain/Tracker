import UIKit

class EditTrackerViewModel {
    let isNew: Bool
    let id: UUID
    let type: TrackerType
    var name: String
    var category: TrackerCategory?
    var schedule: WeekDaySet
    let eventDate: DateWoTime?
    var emojiIndex: Int
    var colorIndex: Int
    var isPinned: Bool

    init(tracker: Tracker) {
        isNew = false
        id = tracker.id
        type = tracker.type
        name = tracker.name
        category = tracker.category
        schedule = tracker.schedule
        eventDate = tracker.eventDate
        emojiIndex = tracker.emojiIndex
        colorIndex = tracker.colorIndex
        isPinned = tracker.isPinned
    }

    init(type: TrackerType, selectedDate: DateWoTime) {
        isNew = true
        id = UUID()
        self.type = type
        name = ""
        category = nil
        schedule = []
        switch type {
        case .event:
            eventDate = selectedDate
        case .habit:
            eventDate = nil
        }
        emojiIndex = 0
        colorIndex = 0
        isPinned = false
    }

    func toTracker() -> Tracker? {
        guard let category, !name.isEmpty, !schedule.isEmpty || eventDate != nil else { return nil }

        return Tracker(
            id: id,
            type: type,
            name: name,
            category: category,
            schedule: schedule,
            eventDate: eventDate,
            emojiIndex: emojiIndex,
            colorIndex: colorIndex,
            isPinned: isPinned,
            records: []
        )
    }
}
