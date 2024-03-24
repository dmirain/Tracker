import UIKit

protocol TrackerViewControllerDepsFactory: AnyObject {
    func getAddController(
        parentDelegate: AddParentDelegateProtocol,
        selectedDate: DateWoTime
    ) -> AddTrackerController?

    func editTrackerController(
        parentDelegate: AddParentDelegateProtocol,
        editTrackerModel: EditTrackerViewModel
    ) -> EditTrackerController?

    func selectFilterController(
        delegate: SelectFilterControllerDelegate,
        currentFilter: TrackerFilter
    ) -> SelectFilterController?
}

final class TrackerListViewController: UIViewController {
    private let depsFactory: TrackerViewControllerDepsFactory
    private let logger: Log
    private let contentView: TrackerListView
    private var openedView: UIViewController?
    private var trackerStore: TrackerStore

    var selectedDate = DateWoTime()
    var selectedFilter = TrackerFilter.all

    init(
        depsFactory: TrackerViewControllerDepsFactory,
        contentView: TrackerListView,
        trackerStore: TrackerStore,
        logger: Log
    ) {
        self.depsFactory = depsFactory
        self.contentView = contentView
        self.trackerStore = trackerStore
        self.logger = logger

        super.init(nibName: nil, bundle: nil)

        self.trackerStore.delegate = self
        self.contentView.controller = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
       self.view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        logger.report(event: .close, screen: .main)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logger.report(event: .open, screen: .main)
    }

    func refreshData() {
        do {
            try trackerStore.fetchData(
                with: FilterParams(date: selectedDate, filter: selectedFilter, name: nil)
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
        contentView.reloadData()
    }
}

extension TrackerListViewController: TrackerListViewDelegate {
    func numberOfSections() -> Int {
        trackerStore.numberOfSections
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        trackerStore.numberOfRowsInSection(section)
    }

    func tracker(byIndexPath: IndexPath) -> TrackerViewModel? {
        guard let tracker = trackerStore.object(atIndexPath: byIndexPath) else { return nil }

        return TrackerViewModel(
            tracker: tracker,
            complitionsCount: tracker.records.count,
            isComplited: tracker.records.contains { $0.date == selectedDate },
            selectedDate: selectedDate
        )
    }

    func sectionTitle(_ section: Int) -> String {
        let name = trackerStore.sectionName(section)
        return name == Constants.pinSlug ? "TrackerList.pinned"~ : name
    }

    func addTrackerClicked() {
        logger.report(event: .click(item: .addTrack), screen: .main)

        let addTrackerController = depsFactory.getAddController(
            parentDelegate: self,
            selectedDate: selectedDate
        )

        guard let addTrackerController else { return }
        let addTrackerNavControllet = UINavigationController(rootViewController: addTrackerController)
        self.openedView = addTrackerNavControllet

        present(addTrackerNavControllet, animated: true)
    }

    func editTrackerClicked(at indexPath: IndexPath) {
        logger.report(event: .click(item: .edit), screen: .main)

        guard let tracker = trackerStore.object(atIndexPath: indexPath) else { return }

        let editTrackerController = depsFactory.editTrackerController(
            parentDelegate: self,
            editTrackerModel: EditTrackerViewModel(tracker: tracker)
        )

        guard let editTrackerController else { return }
        let addTrackerNavControllet = UINavigationController(rootViewController: editTrackerController)
        self.openedView = addTrackerNavControllet

        present(addTrackerNavControllet, animated: true)
    }

    func filterClicked() {
        logger.report(event: .click(item: .filter), screen: .main)

        let selectFilterController = depsFactory.selectFilterController(
            delegate: self,
            currentFilter: selectedFilter
        )

        guard let selectFilterController else { return }

        let controller = UINavigationController(rootViewController: selectFilterController)
        self.openedView = controller

        present(controller, animated: true)
    }

    func deleteTracker(at indexPath: IndexPath) {
        logger.report(event: .click(item: .delete), screen: .main)

        trackerStore.delete(at: indexPath)
    }

    func dateSelected(date: DateWoTime) {
        logger.report(event: .click(item: .dateChanged), screen: .main)

        selectedDate = date
        refreshData()
    }

    func toggleComplete(at indexPath: IndexPath) {
        logger.report(event: .click(item: .track), screen: .main)

        trackerStore.toggleComplete(at: indexPath, on: selectedDate)
    }

    func togglePin(at indexPath: IndexPath) {
        logger.report(event: .click(item: .pinned), screen: .main)

        guard let trackerViewModel = tracker(byIndexPath: indexPath) else { return }
        let model = EditTrackerViewModel(tracker: trackerViewModel.tracker)
        model.isPinned.toggle()
        guard let tracker = model.toTracker() else { return }
        trackerStore.update(record: tracker)
    }
}

extension TrackerListViewController: AddParentDelegateProtocol {
    func compleateEdit(action: EditAction) {
        switch action {
        case .create(let tracker):
            trackerStore.add(tracker)
        case .update(let tracker):
            trackerStore.update(record: tracker)
        case .cancel:
            break
        }
        openedView?.dismiss(animated: true)
        openedView = nil
    }
}

extension TrackerListViewController: StoreDelegate {
    func store(didUpdate update: StoreUpdate) {
        contentView.update(update)
    }
}

extension TrackerListViewController: SelectFilterControllerDelegate {
    func set(filter: TrackerFilter) {
        selectedFilter = filter

        if case filter = .today {
            selectedFilter = .all
            selectedDate = DateWoTime()
        }

        refreshData()

        openedView?.dismiss(animated: true)
        openedView = nil
    }
}
