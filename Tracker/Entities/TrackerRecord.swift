import Foundation

struct TrackerRecord: Codable {
    let id: UUID
    let date: Date
    let tracker: Tracker    
}
