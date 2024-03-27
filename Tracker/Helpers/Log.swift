import AppMetricaCore

protocol Log {
    func report(event: LogEvent, screen: Screen)
}

struct LogImpl: Log {
    func report(event: LogEvent, screen: Screen) {
        var params = ["Screen": screen.rawValue.capitalized]

        switch event {
        case .open:
            print("Screen \(screen.rawValue) opened")
        case .close:
            print("Screen \(screen.rawValue) closed")
        case .click(item: let item):
            print("On screen \(screen.rawValue) clicked \(item.rawValue)")
            params["Item"] = item.rawValue.capitalized
        }

        AppMetrica.reportEvent(
            name: event.name,
            parameters: params,
            onFailure: { error in
                print("Error when sending analytics \(error.localizedDescription)")
            }
        )
    }
}

enum LogEvent {
    case open, close, click(item: LogItem)

    var name: String {
        switch self {
        case .open:
            "Open"
        case .close:
            "Close"
        case .click:
            "Click"
        }
    }
}

enum Screen: String {
    case main, selectFilter
}

enum LogItem: String {
    case addTrack, track, filter, edit, delete, dateChanged, pinned
}
