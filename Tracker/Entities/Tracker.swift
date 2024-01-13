import Foundation
import UIKit

struct Tracker {
    let id: UUID
    let type: TrackerType
    let name: String
    let category: TrackerCategory
    let schedule: UInt8 = 0
    let emoji: String = ""
    let color: UIColor = .ypColorSelection01
}
