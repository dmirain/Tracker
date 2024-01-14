import UIKit

final class TrackerViewController: BaseUIViewController {
    private let contentView: TrackerView
    private let addTrackerController: AddTrackerController

    init(
        contentView: TrackerView,
        addTrackerController: AddTrackerController
    ) {
        self.contentView = contentView
        
        self.addTrackerController = addTrackerController
        
        super.init(nibName: nil, bundle: nil)
        
        self.contentView.controller = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
       self.view = contentView
    }
}

extension TrackerViewController: TrackerViewDelegat {
    func addTrackerClicked() {
        present(addTrackerController, animated: true)
    }
}

protocol TrackerViewDelegat: AnyObject {
    func addTrackerClicked()
}

final class TrackerView: UIView {
    weak var controller: TrackerViewDelegat?

    private lazy var plusButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(.listPlus, for: .normal)
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.backgroundColor = .clear
                
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 42),
            view.widthAnchor.constraint(equalToConstant: 42)
        ])
        
        view.addTarget(self, action: #selector(addTrackerClicked), for: .touchUpInside)
        
        return view
    }()

    private lazy var datePicker: UIDatePicker = {
        let view = UIDatePicker()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.preferredDatePickerStyle = .compact
        view.datePickerMode = .date
        view.locale = Locale(identifier: "ru_Ru")
        view.widthAnchor.constraint(equalToConstant: 93).isActive = true
        return view
    }()

    private lazy var navBar: UINavigationBar = {
        let view = UINavigationBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.barTintColor = .ypWhiteDay
        view.setBackgroundImage(UIImage(), for: .default)
        view.shadowImage = UIImage()
        view.prefersLargeTitles = true
        
        
        let navItem = UINavigationItem()
        navItem.leftBarButtonItem = UIBarButtonItem(customView: plusButton)
        navItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navItem.title = "Трекеры"

        navItem.searchController = UISearchController(searchResultsController: nil)
        navItem.searchController?.searchBar.placeholder = "Поиск"
        navItem.searchController?.searchBar.setValue("Отменить", forKey: "cancelButtonText")

        
        view.setItems([navItem], animated: false)
        
        return view
    }()
        
    private lazy var emptyListView: UIView = {
        let view = EmptyListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var filterButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("Фильтры", for: .normal)
        view.setTitleColor(.ypBlackNight, for: .normal)
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.backgroundColor = .ypBlue
                
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 50),
            view.widthAnchor.constraint(equalToConstant: 114)
        ])
        
//        view.addTarget(self, action: #selector(filterClicked), for: .touchUpInside)
        
        return view
    }()

    init() {
        super.init(frame: .zero)
        
        backgroundColor = UIColor.ypBlackNight

        addSubview(emptyListView)
        addSubview(navBar)
//        addSubview(filterButton)

        NSLayoutConstraint.activate([
            navBar.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            navBar.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            navBar.trailingAnchor.constraint(equalTo: self.trailingAnchor),

            emptyListView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            emptyListView.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            emptyListView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            emptyListView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

//            filterButton.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),
//            filterButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func addTrackerClicked() {
        controller?.addTrackerClicked()
    }
}

final class EmptyListView: UIView {

    private lazy var image: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage.emptyList
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 80),
            view.heightAnchor.constraint(equalToConstant: 80)
        ])
        return view
    }()

    private lazy var lable: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "Что будем отслеживать?"
        view.textColor = .ypWhiteNight
        view.font = view.font.withSize(12)
        return view
    }()

    private lazy var rows: UIStackView = {
        let view = UIStackView(arrangedSubviews: [image, lable])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .center
        view.distribution = .equalSpacing
        view.spacing = 8
        return view
    }()

    init() {
        super.init(frame: .zero)

        backgroundColor = .clear
        addSubview(rows)
        NSLayoutConstraint.activate([
            rows.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            rows.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
