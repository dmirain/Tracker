import UIKit

final class OnboardingPageView: UIView {
    weak var controller: OnboardingPageController?

    let viewModel: OnboardingPageViewModel

    private lazy var image: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = viewModel.image
        return view
    }()

    private lazy var text: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.boldSystemFont(ofSize: 32)
        view.text = viewModel.text
        view.textColor = .ypAlwaysBlack
        view.numberOfLines = 2
        view.textAlignment = .center
        return view
    }()

    private lazy var closeButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.backgroundColor = .ypAlwaysBlack
        view.setTitle(viewModel.buttonText, for: .normal)
        view.setTitleColor(.ypAlwaysWhite, for: .normal)

        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 60)
        ])

        view.addTarget(self, action: #selector(closeClicked), for: .touchUpInside)

        return view
    }()

    init(viewModel: OnboardingPageViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)
        backgroundColor = UIColor.ypAlwaysWhite

        addSubview(image)
        addSubview(text)
        addSubview(closeButton)

        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: self.topAnchor),
            image.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            image.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            image.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            text.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            text.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -270),
            text.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),

            closeButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            closeButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            closeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func closeClicked() {
        controller?.close()
    }
}
