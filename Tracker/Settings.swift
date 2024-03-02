protocol Settings {
    var storeName: String { get }
}

struct SettingsProd: Settings {
    let storeName = "Library"
}
