enum TrackerFilter: String, CaseIterable {
    case all, today, completed, notCompleted

    var asText: String {
        self.rawValue
    }

    var isRed: Bool {
        [Self.completed, .notCompleted].contains(self)
    }
}
