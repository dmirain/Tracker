import Foundation

struct OnboardingState: Codable {
    let isShowed: Bool
}

protocol OnboardingStorage {
    var state: OnboardingState { get set }
}

struct OnboardingStorageImpl: OnboardingStorage {
    var state: OnboardingState {
        get {
            guard let jsonData = userDefaults.data(forKey: storageKey) else { return OnboardingState(isShowed: false) }
            guard let dto = jsonData.fromJson(to: OnboardingState.self) else { return OnboardingState(isShowed: false) }
            return dto
        }
        set(newValue) {
            guard let jsonData = Data.toJson(from: newValue) else { return }
            userDefaults.set(jsonData, forKey: storageKey)
        }
    }

    private let storageKey = "OnboardingState"
    private let userDefaults = UserDefaults.standard
}
