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
    
    func initData(trackers: [Tracker]) {
        categories = []
        groupedTrackers = [:]
        
        if trackers.isEmpty {
            emptyListView.isHidden = false
            return
        }
        
        categories = Array(Set(trackers.map({ tracker in tracker.category })))
        for tracker in trackers {
            if groupedTrackers[tracker.category] != nil {
                groupedTrackers[tracker.category]?.append(tracker)
            } else {
                groupedTrackers[tracker.category] = [tracker]
            }
        }
        
        collectionView.reloadData()
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
        let category = categories[indexPath.section]
        let tracker = groupedTrackers[category]![indexPath.row]
        cell.initData(tracker: tracker)
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