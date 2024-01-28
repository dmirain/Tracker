import UIKit

class SectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "SectionHeaderView"

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.boldSystemFont(ofSize: 19)
        return view
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setTitle(_ title: String, spacing: CGFloat) {
        addSubview(titleLabel)

        titleLabel.text = title
        
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -spacing),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
