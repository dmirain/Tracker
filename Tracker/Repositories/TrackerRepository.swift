import Foundation

var trackersStorage: [Tracker] = [
    Tracker(
        id: UUID(),
        type: .event,
        name: "Test",
        category: TrackerCategory(name: "Тест"),
        schedule: .monday,
        emojiIndex: 1,
        colorIndex: 2
    )
]

final class TrackerRepository {

    func create(_ new: Tracker) {
        trackersStorage.append(new)
    }

    func filter(byDate date: DateWoTime? = nil, byName name: String? = nil) -> [Tracker] {
        var result = trackersStorage

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
