import UIKit

struct OnboardingViewModel {
    let pages: [OnboardingPageViewModel]
}

struct OnboardingPageViewModel {
    let image: UIImage
    let text: String
    let buttonText: String
}
