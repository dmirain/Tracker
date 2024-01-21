import UIKit

final class EmojiCell: UICollectionViewCell {
    static let reuseIdentifier = "EmojiCell"
    weak var delegate: CreateTrackerView?
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = view.font.withSize(32)
        view.textAlignment = .center
        return view
    }()

    private lazy var container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.backgroundColor = .clear
        
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 52),
            view.heightAnchor.constraint(equalToConstant: 52),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(container)

        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setEmoji(_ emoji: String) {
        titleLabel.text = emoji
    }
    
    func setSelected() {
        container.backgroundColor = .ypLightGray
    }
    
    func setDeselected() {
        container.backgroundColor = .clear
    }
}
