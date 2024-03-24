import Foundation

private let calendar = Calendar(identifier: .gregorian)

struct WeekDaySet: OptionSet, Codable, Hashable {
    static let sunday    = Self(rawValue: 1 << 0)
    static let monday = Self(rawValue: 1 << 1)
    static let tuesday   = Self(rawValue: 1 << 2)
    static let wednesday = Self(rawValue: 1 << 3)
    static let thursday   = Self(rawValue: 1 << 4)
    static let friday = Self(rawValue: 1 << 5)
    static let saturday   = Self(rawValue: 1 << 6)

    let rawValue: Int

    static func from(date: DateWoTime) -> Self {
        let dayNum = calendar.dateComponents([.weekday], from: date.value).weekday
        let dayValue = 1 << (dayNum! - 1)  // сдвиг 1 по битовым разрядам. это возведение 2 в степень
        return Self(rawValue: dayValue)
    }

    static func allDays() -> [Self] {
        [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    }

    func asText() -> String {
        switch self {
        case .monday:
            return "monday"~
        case .tuesday:
            return "tuesday"~
        case .wednesday:
            return "wednesday"~
        case .thursday:
            return "thursday"~
        case .friday:
            return "friday"~
        case .saturday:
            return "saturday"~
        case .sunday:
            return "sunday"~
        default:
            return Self.allDays()
                .filter { day in self.contains(day) }
                .map({ day in day.asText() })
                .joined(separator: ", ")
        }
    }

    func asShortText() -> String {
        switch self {
        case .monday:
            return "monday.short"~
        case .tuesday:
            return "tuesday.short"~
        case .wednesday:
            return "wednesday.short"~
        case .thursday:
            return "thursday.short"~
        case .friday:
            return "friday.short"~
        case .saturday:
            return "saturday.short"~
        case .sunday:
            return "sunday.short"~
        default:
            return Self.allDays()
                .filter { day in self.contains(day) }
                .map({ day in day.asShortText() })
                .joined(separator: ", ")
        }
    }
}
