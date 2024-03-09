import UIKit

protocol OnboardingPageControllerDelegate: AnyObject {
    func close()
}

final class OnboardingPageController: UIViewController {
    weak var delegate: OnboardingPageControllerDelegate?

    private let contentView: OnboardingPageView

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }

    init(delegate: OnboardingPageControllerDelegate, viewModel: OnboardingPageViewModel) {
        self.delegate = delegate
        self.contentView = OnboardingPageView(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)

        self.contentView.controller = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
       self.view = contentView
    }

    func close() {
        delegate?.close()
    }
}
