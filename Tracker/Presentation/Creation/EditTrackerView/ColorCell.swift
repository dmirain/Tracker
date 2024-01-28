import UIKit

final class ColorCell: UICollectionViewCell {
    static let reuseIdentifier = "ColorCell"
    
    weak var delegate: EditTrackerView?
    
    private lazy var colorLabel: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 40),
            view.heightAnchor.constraint(equalToConstant: 40),
        ])
        return view
    }()

    private lazy var container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.backgroundColor = .clear
        view.layer.borderColor = UIColor.ypGray.cgColor
        
        view.addSubview(colorLabel)
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 52),
            view.heightAnchor.constraint(equalToConstant: 52),

            colorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            colorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(container)
        
        NSLayoutConstraint.activate([
            colorLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setColor(_ color: UIColor, isSelected: Bool) {
        colorLabel.backgroundColor = color
        container.layer.borderWidth = isSelected ? 3 : 0
    }
}
