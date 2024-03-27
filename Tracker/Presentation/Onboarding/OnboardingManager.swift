final class OnboardingManager {
    private var storage: OnboardingStorage

    init(storage: OnboardingStorage) {
        self.storage = storage
    }

    func forShow() -> OnboardingController? {
        if storage.state.isShowed { return nil }

        let viewModel = OnboardingViewModel(
            pages: [
                OnboardingPageViewModel(
                    image: .obImageFirst,
                    text: "Onboarding.first.text"~,
                    buttonText: "Onboarding.first.buttonText"~
                ),
                OnboardingPageViewModel(
                    image: .obImageSecond,
                    text: "Onboarding.second.text"~,
                    buttonText: "Onboarding.second.buttonText"~
                )
            ]
        )

        let controller = OnboardingController(viewModel: viewModel, onboardingManager: self)
        return controller
    }

    func showed() {
        storage.state = OnboardingState(isShowed: true)
    }
}
