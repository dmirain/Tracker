import Foundation
import UIKit

struct Tracker: Codable {
    let id: UUID
    let type: TrackerType
    let name: String
    let category: TrackerCategory
    let schedule: UInt8
    let emoji: String
//    let color: UIColor
}
