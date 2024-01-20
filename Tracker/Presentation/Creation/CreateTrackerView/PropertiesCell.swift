import UIKit

final class PropertiesCell: UICollectionViewCell {
    static let reuseIdentifier = "PropertiesCell"
    
    weak var delegate: CreateTrackerView?
    
    private lazy var separator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .ypGray
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 0.5),
        ])
        
        return view
    }()
    
    private func rightArrow() -> UIImageView {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = .rightArrow
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 24),
            view.widthAnchor.constraint(equalToConstant: 24),
        ])
        
        return view
    }
    
    private lazy var categoryButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .ypBackgroundDay
        view.setTitle("Категория", for: .normal)
        view.setTitleColor(.ypBlackDay, for: .normal)
        view.contentHorizontalAlignment = .left
        view.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        
        let rightArrow = rightArrow()
        view.addSubview(rightArrow)
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 75),
            
            rightArrow.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            rightArrow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        view.addTarget(self, action: #selector(categoryButtonClicked), for: .touchUpInside)
        
        return view
    }()
    
    private lazy var scheduleButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .ypBackgroundDay
        view.setTitle("Расписание", for: .normal)
        view.setTitleColor(.ypBlackDay, for: .normal)
        view.contentHorizontalAlignment = .left
        view.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        
        let rightArrow = rightArrow()
        view.addSubview(rightArrow)
        view.addSubview(separator)
        
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 75),
            
            separator.topAnchor.constraint(equalTo: view.topAnchor),
            separator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            rightArrow.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            rightArrow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        view.addTarget(self, action: #selector(scheduleButtonClicked), for: .touchUpInside)
        
        return view
    }()
    
    private lazy var buttonsStack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [categoryButton, scheduleButton])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.axis = .vertical
        view.spacing = 0
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    func categoryButtonClicked() {
        print("categoryButtonClicked")
    }
    
    @objc
    func scheduleButtonClicked() {
        print("scheduleButtonClicked")
    }
}
