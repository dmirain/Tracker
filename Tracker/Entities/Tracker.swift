import Foundation
import UIKit

struct Tracker: Codable {
    let id: UUID
    let type: TrackerType
    let name: String
    let category: TrackerCategory
    let schedule: WeekDaySet
    let emoji: String
//    let color: UIColor
}
