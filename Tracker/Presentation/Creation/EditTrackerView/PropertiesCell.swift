import UIKit

final class PropertiesCell: UICollectionViewCell {
    static let reuseIdentifier = "PropertiesCell"
    
    weak var delegate: EditTrackerView?
        
    private lazy var categoryButton: PropertyButton = {
        let view = PropertyButton(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("Категория", for: .normal)
                
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 75),
        ])
        
        view.addTarget(self, action: #selector(categoryButtonClicked), for: .touchUpInside)
        return view
    }()
    
    private lazy var scheduleButton: PropertyButton = {
        let view = PropertyButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("Расписание", for: .normal)
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 75),
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

    func setProperties(category: TrackerCategory?, schedule: WeekDaySet, type: TrackerType) {
        if let category {
            categoryButton.setSubTitle(category.name)
        }
        
        if type == .habit {
            scheduleButton.setSubTitle(schedule.asShortText())
            scheduleButton.isHidden = false
        } else {
            scheduleButton.isHidden = true
        }
    }
    
    @objc
    private func categoryButtonClicked() {
        delegate?.selectCategory()
    }
    
    @objc
    private func scheduleButtonClicked() {
        delegate?.selectSchedule()
    }
}
