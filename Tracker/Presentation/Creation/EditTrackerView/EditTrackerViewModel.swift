import UIKit

class EditTrackerViewModel {
    let id: UUID
    let type: TrackerType
    var name: String
    var category: TrackerCategory?
    var schedule: WeekDaySet
    var emojiIndex: Int
    var colorIndex: Int
    
    init(tracker: Tracker) {
        id = tracker.id
        type = tracker.type
        name = tracker.name
        category = tracker.category
        schedule = tracker.schedule
        emojiIndex = tracker.emojiIndex
        colorIndex = tracker.colorIndex
    }

    init(type: TrackerType) {
        id = UUID()
        self.type = type
        name = ""
        category = nil
        schedule = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        emojiIndex = 0
        colorIndex = 0
    }
    
    func toTracker() -> Tracker? {
        guard let category, !name.isEmpty, !schedule.isEmpty else { return nil }
        
        return Tracker(
            id: id,
            type: type, 
            name: name,
            category: category,
            schedule: schedule,
            emojiIndex: emojiIndex,
            colorIndex: colorIndex
        )
    }
}
