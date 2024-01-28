import Foundation
import UIKit

protocol AddTrackerViewDelegat: AnyObject {
    func createClicked(type: TrackerType)
}

final class AddTrackerView: UIView {
    weak var controller: AddTrackerViewDelegat?
    
    private lazy var header: UINavigationBar = {
        let view = UINavigationBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.barTintColor = .ypWhite
        view.setBackgroundImage(UIImage(), for: .default)
        view.shadowImage = UIImage()
                
        let navItem = UINavigationItem()
        navItem.title = "Создание трекера"
        
        view.setItems([navItem], animated: false)
        
        return view
    }()    
    
    private lazy var createHabit: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.backgroundColor = .ypBlack
        view.setTitle("Привычка", for: .normal)
        view.setTitleColor(.ypWhite, for: .normal)
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 60),
        ])
        
        view.addTarget(self, action: #selector(createHabitClicked), for: .touchUpInside)
        
        return view
    }()
    
    private lazy var createEvent: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.backgroundColor = .ypBlack
        view.setTitle("Нерегулярные событие", for: .normal)
        view.setTitleColor(.ypWhite, for: .normal)

        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        view.addTarget(self, action: #selector(createEventClicked), for: .touchUpInside)
        
        return view
    }()
    
    private lazy var buttonsStack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [createHabit, createEvent])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .center
        view.spacing = 16
        view.contentMode = .top
        view.distribution = .equalSpacing
        
        NSLayoutConstraint.activate([
            createHabit.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            createHabit.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            createEvent.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            createEvent.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        return view
    }()
    
    
    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor.ypWhite
        
        addSubview(header)
        addSubview(buttonsStack)
        
        NSLayoutConstraint.activate([
            header.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            header.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            header.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            buttonsStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            buttonsStack.topAnchor.constraint(equalTo: self.bottomAnchor, constant: -417),
            buttonsStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func createHabitClicked() {
        controller?.createClicked(type: .habit)
    }
    @objc
    private func createEventClicked() {
        controller?.createClicked(type: .event)
    }
}
