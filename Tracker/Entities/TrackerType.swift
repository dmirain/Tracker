enum TrackerType: String, Codable {
    case event
    case habit

    func asText() -> String {
        switch self {
        case .event:
            "TrackerType.event"~
        case .habit:
            "TrackerType.habit"~
        }
    }
}
