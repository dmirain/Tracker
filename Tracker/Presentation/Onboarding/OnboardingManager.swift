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
                    text: "Отслеживайте только то, что хотите",
                    buttonText: "Вот это технологии!"
                ),
                OnboardingPageViewModel(
                    image: .obImageSecond,
                    text: "Даже если это не литры воды и йога",
                    buttonText: "Вот это технологии!"
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
