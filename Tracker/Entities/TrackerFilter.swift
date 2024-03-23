enum TrackerFilter: String, CaseIterable {
    case all, today, completed, notCompleted
    
    var asText: String {
        return self.rawValue
    }
}
