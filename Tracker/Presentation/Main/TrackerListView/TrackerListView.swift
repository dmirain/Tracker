import UIKit

protocol TrackerListViewDelegate: AnyObject {
    var viewModel: TrackerListViewModel { get }
    func addTrackerClicked()
    func dateSelected(date: DateWoTime)
    func toggleComplete(_ tracker: Tracker)
}

final class TrackerListView: UIView {
    weak var controller: TrackerListViewDelegate?

    private lazy var datePicker: UIDatePicker = {
        let view = UIDatePicker()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.preferredDatePickerStyle = .compact
        view.datePickerMode = .date
        view.locale = Locale(identifier: "ru_Ru")
        view.widthAnchor.constraint(equalToConstant: 120).isActive = true

        view.addTarget(self, action: #selector(dateSelected(_:)), for: .valueChanged)

        return view
    }()

    private lazy var navBar: UINavigationBar = {
        let view = UINavigationBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.barTintColor = .ypWhite
        view.setBackgroundImage(UIImage(), for: .default)
        view.shadowImage = UIImage()
        view.prefersLargeTitles = true
        view.backgroundColor = .ypWhite

        let navItem = UINavigationItem()
        navItem.leftBarButtonItem = UIBarButtonItem(
            image: .listPlus, style: .plain, target: self, action: #selector(addTrackerClicked)
        )
        navItem.leftBarButtonItem?.tintColor = .ypBlack
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
        view.backgroundColor = .ypWhite

        view.register(TrackerListCell.self, forCellWithReuseIdentifier: TrackerListCell.reuseIdentifier)
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
        view.setTitleColor(.ypWhite, for: .normal)
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

        backgroundColor = .ypWhite

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
            filterButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -16)
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

    @objc
    private func dateSelected(_ sender: UIDatePicker) {
        controller?.dateSelected(date: DateWoTime(sender.date))
    }

    func reload() {
        if controller?.viewModel.numberOfCategories ?? 0 == 0 {
            emptyListView.isHidden = false
        } else {
            emptyListView.isHidden = true
            collectionView.reloadData()
        }
    }

    func toggleComplete(_ tracker: Tracker) {
        controller?.toggleComplete(tracker)
    }
}

extension TrackerListView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        controller?.viewModel.numberOfCategories ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        controller?.viewModel.numberOfTrackersInCategory(byIndex: section) ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerListCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerListCell

        guard let cell, let viewModel = controller?.viewModel else { return UICollectionViewCell() }

        cell.delegate = self
        let trackerViewModel = viewModel.tracker(byIndexPath: indexPath)
        cell.initData(trackerViewModel: trackerViewModel)

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let sectionTitle = controller?.viewModel.categoryName(byIndex: indexPath.section) ?? ""

        guard !sectionTitle.isEmpty && kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier,
            for: indexPath
        ) as? SectionHeaderView

        guard let view else { return UICollectionReusableView() }

        view.setTitle(sectionTitle, spacing: 12)
        return view
    }
}

extension TrackerListView: UICollectionViewDelegateFlowLayout {
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
        CGSize(width: (collectionView.bounds.width - 8) / 2, height: 140)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 42)
    }

}
