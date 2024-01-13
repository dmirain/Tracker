import Foundation

let calendar = Calendar(identifier: .gregorian)

enum WeekDay: UInt8 {
    case sunday = 1  // "0000001"  первый день недели по мнению swift
    case monday = 2  // "0000010"
    case tuesday = 4  // "0000100"
    case wednesday = 8  // "0001000"
    case thursday = 16  // "0010000"
    case friday = 32  // "0100000"
    case saturday = 64  // "1000000"
    
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
        }
    }
    
    static func from(date: Date) -> WeekDay {
        let dayNum = Calendar.current.dateComponents([.weekday], from: date).weekday
        let dayValue = 0x1 << (dayNum! - 1)
        return WeekDay(rawValue: UInt8(dayValue))!
    }
    
    func inSchedule(_ schedule: UInt8) -> Bool {
        return self.rawValue & schedule > 0
    }
    
    static func sheduleToWeekDays(_ schedule: UInt8) -> [WeekDay] {
        let weekDays: [WeekDay] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        return weekDays.filter { weekDay in
            weekDay.inSchedule(schedule)
        }
    }
}
