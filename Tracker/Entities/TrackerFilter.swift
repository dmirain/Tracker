enum TrackerFilter: String, CaseIterable {
    case all, today, completed, notCompleted

    var asText: String {
        switch self {
        case .all:
            "TrackerFilter.all"~
        case .today:
            "TrackerFilter.today"~
        case .completed:
            "TrackerFilter.completed"~
        case .notCompleted:
            "TrackerFilter.notCompleted"~
        }
    }

    var isRed: Bool {
        [Self.completed, .notCompleted].contains(self)
    }
}
