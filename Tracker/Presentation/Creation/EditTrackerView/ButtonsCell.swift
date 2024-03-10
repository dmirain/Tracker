import UIKit

final class ButtonsCell: UICollectionViewCell {
    static let reuseIdentifier = "ButtonsCell"

    weak var delegate: EditTrackerView?

    private lazy var cancelButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.backgroundColor = .ypWhite
        view.setTitle("Отменить", for: .normal)
        view.setTitleColor(.ypRed, for: .normal)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.ypRed.cgColor

        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 60)
        ])

        view.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)

        return view
    }()

    private lazy var createButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.backgroundColor = .ypGray
        view.setTitle("Создать", for: .normal)
        view.setTitleColor(.ypWhite, for: .normal)

        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 60)
        ])

        view.addTarget(self, action: #selector(createButtonClicked), for: .touchUpInside)

        return view
    }()

    private lazy var buttonsStack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [cancelButton, createButton])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = 8
        view.distribution = .fillEqually
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(buttonsStack)

        NSLayoutConstraint.activate([
            buttonsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            buttonsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            buttonsStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setButtonsState(to state: ButtonsState) {
        switch state {
        case .save:
            createButton.isEnabled = true
            createButton.backgroundColor = .ypBlack
        case .edit:
            createButton.isEnabled = false
            createButton.backgroundColor = .ypGray
        }
    }

    @objc
    private func cancelButtonClicked() {
        delegate?.compleateEdit(action: .cancel)
    }

    @objc
    private func createButtonClicked() {
        delegate?.compleateEdit(action: .save)
    }
}

enum ButtonsState {
    case save, edit
}
