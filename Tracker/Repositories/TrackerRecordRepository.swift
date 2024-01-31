import Foundation

private var completedTrackers: [TrackerRecord] = [
    TrackerRecord(
        id: UUID(),
        date: DateWoTime(),
        trackerId: trackersStorage[0].id
    )
]

final class TrackerRecordRepository {
    func toggleComplete(_ tracker: Tracker, on date: DateWoTime) {
        let count = completedTrackers.count
        completedTrackers = completedTrackers.filter {
            $0.trackerId != tracker.id || $0.date != date
        }
        if completedTrackers.count == count {
            completedTrackers.append(TrackerRecord(id: UUID(), date: date, trackerId: tracker.id))
        }
    }

    func filter(trackers: [Tracker]) -> [TrackerRecord] {
        let trackerIds = Set(trackers.map { $0.id })
        return completedTrackers.filter { trackerIds.contains($0.trackerId) }
    }
}
