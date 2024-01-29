import Foundation

struct TrackerRecord: Codable, Identifiable, Hashable {
    let id: UUID
    let date: DateWoTime
    let trackerId: UUID
}
