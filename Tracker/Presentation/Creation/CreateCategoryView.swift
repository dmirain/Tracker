import UIKit

final class CreateCategoryView: UIView {
    weak var controller: CreateCategoryController?

    private lazy var nameField: PaddingTextField = {
        let view = PaddingTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Введите название категории"
        view.backgroundColor = .ypBackground
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.textColor = .ypBlack

        view.addTarget(self, action: #selector(nameChanged), for: .allEditingEvents)

        view.heightAnchor.constraint(equalToConstant: 75).isActive = true

        return view
    }()

    private lazy var createButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.backgroundColor = .ypGray
        view.setTitle("Готово", for: .normal)
        view.setTitleColor(.ypWhite, for: .normal)

        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 60)
        ])

        view.addTarget(self, action: #selector(createButtonClicked), for: .touchUpInside)

        return view
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor.ypWhite

        addSubview(nameField)
        addSubview(createButton)

        NSLayoutConstraint.activate([
            nameField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            nameField.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),

            createButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            createButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func nameChanged() {
        guard let controller else { return }

        controller.viewModel.name = nameField.text ?? ""

        if controller.viewModel.name.isEmpty {
            createButton.isEnabled = false
            createButton.backgroundColor = .ypGray
        } else {
            createButton.isEnabled = true
            createButton.backgroundColor = .ypBlack
        }
    }

    @objc
    private func createButtonClicked() {
        controller?.compliteCreate()
    }
}
