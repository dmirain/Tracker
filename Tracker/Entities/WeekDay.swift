import Foundation

let calendar = Calendar(identifier: .gregorian)

struct WeekDaySet: OptionSet, Codable, Hashable {
    let rawValue: Int
    
    static let sunday    = WeekDaySet(rawValue: 1 << 0)
    static let monday  = WeekDaySet(rawValue: 1 << 1)
    static let tuesday   = WeekDaySet(rawValue: 1 << 2)
    static let wednesday   = WeekDaySet(rawValue: 1 << 3)
    static let thursday   = WeekDaySet(rawValue: 1 << 4)
    static let friday   = WeekDaySet(rawValue: 1 << 5)
    static let saturday   = WeekDaySet(rawValue: 1 << 6)
    
    static func from(date: Date) -> WeekDaySet {
        let dayNum = calendar.dateComponents([.weekday], from: date).weekday
        let dayValue = 1 << (dayNum! - 1)  // сдвиг 1 по битовым разрядам. это возведение 2 в степень
        return WeekDaySet(rawValue: dayValue)
    }
    
    static func allDays() -> [WeekDaySet] {
        [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    }
    
    func asText() -> String {
        switch self {
        case .monday:
            return "Понедельник"
        case .tuesday:
            return "Вторник"
        case .wednesday:
            return "Среда"
        case .thursday:
            return "Четверг"
        case .friday:
            return "Пятница"
        case .saturday:
            return "Суббота"
        case .sunday:
            return "Воскресенье"
        default:
            return WeekDaySet.allDays()
                .filter { day in self.contains(day) }
                .map({ day in day.asText()})
                .joined(separator: ", ")
        }
    }
    
    func asShortText() -> String {
        switch self {
        case .monday:
            return "Пн"
        case .tuesday:
            return "Вт"
        case .wednesday:
            return "Ср"
        case .thursday:
            return "Чт"
        case .friday:
            return "Пт"
        case .saturday:
            return "Сб"
        case .sunday:
            return "Вс"
        default:
            return WeekDaySet.allDays()
                .filter { day in self.contains(day) }
                .map({ day in day.asShortText()})
                .joined(separator: ", ")
        }
    }
}
