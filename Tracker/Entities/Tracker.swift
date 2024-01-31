import Foundation
import UIKit

private let trackerColors: [UIColor] = [
    .ypColorSelection01,
    .ypColorSelection02,
    .ypColorSelection03,
    .ypColorSelection04,
    .ypColorSelection05,
    .ypColorSelection06,
    .ypColorSelection07,
    .ypColorSelection08,
    .ypColorSelection09,
    .ypColorSelection10,
    .ypColorSelection11,
    .ypColorSelection12,
    .ypColorSelection13,
    .ypColorSelection14,
    .ypColorSelection15,
    .ypColorSelection16,
    .ypColorSelection17,
    .ypColorSelection18
]

private let trackerEmojies = [
    "🙂", "😻", "🌺", "🐶", "❤️", "😱",
    "😇", "😡", "🥶", "🤔", "🙌", "🍔",
    "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
]

struct Tracker: Codable, Identifiable, Hashable {
    let id: UUID
    let type: TrackerType
    let name: String
    let category: TrackerCategory
    let schedule: WeekDaySet
    let eventDate: DateWoTime?
    let emojiIndex: Int
    let colorIndex: Int

    var emoji: String { Self.emoji(byIndex: emojiIndex) }
    var color: UIColor { Self.color(byIndex: colorIndex) }

    static func emoji(byIndex index: Int) -> String { trackerEmojies[index] }
    static func color(byIndex index: Int) -> UIColor { trackerColors[index] }
}
