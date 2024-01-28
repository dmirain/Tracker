import Foundation

private var trackers: [Tracker] = [Tracker(
    id: UUID(),
    type: .event, 
    name: "Test", 
    category: TrackerCategory(name: "Тест"),
    schedule: .sunday, 
    emojiIndex: 1,
    colorIndex: 2)
]

final class TrackerRepository {

    func create(_ new: Tracker) {
        trackers.append(new)
    }
    
    func filter(byDate date: Date? = nil, byName name: String? = nil) -> [Tracker] {
        var result = trackers
        
        if let date {
            let weekDay = WeekDaySet.from(date: date)
            result = result.filter { tracker in
                tracker.schedule.contains(weekDay)
            }
        }

        if let name {
            result = result.filter { tracker in
                tracker.name.contains(name)
            }
        }

        return result
    }
}
