protocol Settings {
    var storeName: String { get }
}

struct SettingsProd: Settings {
    let storeName = "Library"
}

struct Constants {
    static let pinSlug = "__pinned__"
}
