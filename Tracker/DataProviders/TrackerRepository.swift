import Foundation

var trackersStorage: [Tracker] = [
    Tracker(
        id: UUID(),
        type: .habit,
        name: "Test habit",
        category: TrackerCategory(name: "Home"),
        schedule: .monday,
        eventDate: nil,
        emojiIndex: 1,
        colorIndex: 2
    ),
    Tracker(
        id: UUID(),
        type: .event,
        name: "Test event",
        category: TrackerCategory(name: "Work"),
        schedule: [],
        eventDate: DateWoTime(),
        emojiIndex: 4,
        colorIndex: 7
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
                tracker.schedule.contains(weekDay) || tracker.eventDate == date
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
