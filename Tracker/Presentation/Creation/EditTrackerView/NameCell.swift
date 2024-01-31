import UIKit

final class NameCell: UICollectionViewCell {
    static let reuseIdentifier = "NameCell"

    weak var delegate: EditTrackerView?

    private lazy var nameField: PaddingTextField = {
        let view = PaddingTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Введите название трекера"
        view.backgroundColor = .ypBackground
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.textColor = .ypBlack

        view.addTarget(self, action: #selector(nameChanged), for: .allEditingEvents)

        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(nameField)

        NSLayoutConstraint.activate([
            nameField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameField.topAnchor.constraint(equalTo: contentView.topAnchor),
            nameField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setName(name: String) {
        nameField.text = name
    }

    @objc
    private func nameChanged() {
        delegate?.nameChanged(nameField.text ?? "")
    }
}
