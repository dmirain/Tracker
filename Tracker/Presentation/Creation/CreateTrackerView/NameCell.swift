import UIKit

final class NameCell: UICollectionViewCell {
    static let reuseIdentifier = "NameCell"
    
    weak var delegate: CreateTrackerView?

    lazy var nameField: PaddingTextField = {
        let view = PaddingTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Введите название трекера"
        view.backgroundColor = .ypBackgroundDay
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true

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
}
