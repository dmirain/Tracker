import UIKit

protocol TrackerViewDelegat: AnyObject {
    func addTrackerClicked()
}

final class TrackerView: UIView {
    weak var controller: TrackerViewDelegat?

    private var categories = [TrackerCategory]()
    private var groupedTrackers = [TrackerCategory: [Tracker]]()
    
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
        view.widthAnchor.constraint(equalToConstant: 120).isActive = true
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
        
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.allowsMultipleSelection = false
        
        view.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        view.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier
        )
        
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
        view.setTitleColor(.ypWhiteDay, for: .normal)
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

        collectionView.dataSource = self
        collectionView.delegate = self
        
        ///
        ///
        let catHome = TrackerCategory(name: "Дом")
        let catWork = TrackerCategory(name: "Работа")

        let tracker1 = Tracker(
            id: UUID(),
            type: .event,
            name: "Прожарка",
            category: catWork,
            schedule: [.monday, .tuesday, .friday], 
            emoji: 1, 
            color: 1
        )

        let tracker2 = Tracker(
            id: UUID(),
            type: .event,
            name: "Review",
            category: catWork,
            schedule: [.friday],
            emoji: 3,
            color: 4
        )

        let tracker3 = Tracker(
            id: UUID(),
            type: .event,
            name: "Уборка",
            category: catHome,
            schedule: .thursday,
            emoji: 5,
            color: 5
        )
        
        categories = [catWork, catHome]
        groupedTrackers[catHome] = [tracker3]
        groupedTrackers[catWork] = [tracker1, tracker2]
        
        ///
        addSubview(navBar)
        addSubview(collectionView)
        addSubview(filterButton)
        addSubview(emptyListView)

        NSLayoutConstraint.activate([
            navBar.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            navBar.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            navBar.trailingAnchor.constraint(equalTo: self.trailingAnchor),

            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            collectionView.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),

            emptyListView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            emptyListView.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            emptyListView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            emptyListView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),

            filterButton.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])

        emptyListView.isHidden = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func addTrackerClicked() {
        controller?.addTrackerClicked()
    }
}


extension TrackerView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        categories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let category = categories[section]
        return groupedTrackers[category]?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerCell
        guard let cell else { return UICollectionViewCell() }
        cell.delegate = self
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let sectionTitle = categories[indexPath.section].name
        
        guard !sectionTitle.isEmpty && kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier,
            for: indexPath
        ) as! SectionHeaderView
        
        view.titleLabel.text = sectionTitle

        return view
    }
}

extension TrackerView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _: UICollectionView,
        layout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt: Int
    ) -> CGFloat {
        8
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 8) / 2 , height: 140)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 42)
    }

}

final class TrackerCell: UICollectionViewCell {
    static let reuseIdentifier = "TrackerCell"
    weak var delegate: TrackerView?
    
    private lazy var emojiLable: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false

        view.backgroundColor = .ypWhite30
        view.text = "🌺"
        view.textAlignment = .center
        view.font = UIFont.systemFont(ofSize: 12)
        
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 24),
            view.widthAnchor.constraint(equalToConstant: 24),
        ])
        
        return view
    }()

    private lazy var nameLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 2
        
        view.text = "Какой-то текст"
        view.textColor = .ypWhiteDay
        view.font = view.font.withSize(12)

        return view
    }()

    private lazy var periodeLable: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false

        view.text = "5 дней"
        view.font = view.font.withSize(12)

        return view
    }()

    private lazy var compliteButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .ypColorSelection04

        if Bool.random() {
            view.setImage(.complited, for: .normal)
            view.layer.opacity = 0.3
        } else {
            view.setImage(.toComplite, for: .normal)
        }

        view.imageEdgeInsets = UIEdgeInsets(top: 11, left: 11, bottom: 11, right: 11)

        view.layer.cornerRadius = 17
        view.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 34),
            view.widthAnchor.constraint(equalToConstant: 34)
        ])
        
        view.addTarget(self, action: #selector(compliteButtonClicked), for: .touchUpInside)
        
        return view
    }()

    private lazy var nameView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .ypColorSelection04

        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        
        view.addSubview(emojiLable)
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 90),

            emojiLable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            emojiLable.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),

            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            nameLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
        ])
        return view
    }()

    private lazy var stateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(periodeLable)
        view.addSubview(compliteButton)
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 50),
        
            periodeLable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            periodeLable.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            compliteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            compliteButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(nameView)
        contentView.addSubview(stateView)

        
        NSLayoutConstraint.activate([
            nameView.topAnchor.constraint(equalTo: contentView.topAnchor),
            nameView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            stateView.topAnchor.constraint(equalTo: nameView.bottomAnchor),
            stateView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stateView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stateView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    func compliteButtonClicked() {
        print("compliteButtonClicked")
    }
}
