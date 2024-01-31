import Foundation

private var calendar = Calendar.current

struct DateWoTime: Codable, Equatable, Hashable {
    let value: Date

    init() {
        value = Self.clearTime(Date())
    }

    init(_ date: Date) {
        value = Self.clearTime(date)
    }

    private static func clearTime(_ date: Date) -> Date {
        calendar.timeZone = TimeZone.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: dateComponents) ?? Date()
    }

    static func == (_ left: Self, _ right: Self) -> Bool {
        left.value == right.value
    }
    static func > (_ left: Self, _ right: Self) -> Bool {
        left.value > right.value
    }
    static func < (_ left: Self, _ right: Self) -> Bool {
        left.value < right.value
    }
    static func >= (_ left: Self, _ right: Self) -> Bool {
        left.value >= right.value
    }
    static func <= (_ left: Self, _ right: Self) -> Bool {
        left.value <= right.value
    }
}
