import UIKit

protocol TrackerViewControllerDepsFactory: AnyObject {
    func getAddController(
        parentDelegate: AddParentDelegateProtocol,
        selectedDate: DateWoTime
    ) -> AddTrackerController?

    func editTrackerController(
        parentDelegate: AddParentDelegateProtocol,
        editTrackerModel: EditTrackerViewModel
    ) -> EditTrackerController?}

final class TrackerListViewController: UIViewController {
    private let depsFactory: TrackerViewControllerDepsFactory
    private let contentView: TrackerListView
    private var addTrackerNavControllet: UINavigationController?
    private var trackerStore: TrackerStore

    private var selectedDate = DateWoTime()

    init(
        depsFactory: TrackerViewControllerDepsFactory,
        contentView: TrackerListView,
        trackerStore: TrackerStore
    ) {
        self.depsFactory = depsFactory
        self.contentView = contentView
        self.trackerStore = trackerStore

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

    func refreshData() {
        do {
            try trackerStore.fetchData(with: FilterParams(date: selectedDate, name: nil))
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
        return name == Constants.pinSlug ? "Закреплённые" : name
    }

    func addTrackerClicked() {
        let addTrackerController = depsFactory.getAddController(
            parentDelegate: self,
            selectedDate: selectedDate
        )

        guard let addTrackerController else { return }
        let addTrackerNavControllet = UINavigationController(rootViewController: addTrackerController)
        self.addTrackerNavControllet = addTrackerNavControllet

        present(addTrackerNavControllet, animated: true)
    }

    func editTrackerClicked(at indexPath: IndexPath) {
        guard let tracker = trackerStore.object(atIndexPath: indexPath) else { return }

        let editTrackerController = depsFactory.editTrackerController(
            parentDelegate: self,
            editTrackerModel: EditTrackerViewModel(tracker: tracker)
        )

        guard let editTrackerController else { return }
        let addTrackerNavControllet = UINavigationController(rootViewController: editTrackerController)
        self.addTrackerNavControllet = addTrackerNavControllet

        present(addTrackerNavControllet, animated: true)
    }

    func deleteTracker(at indexPath: IndexPath) {
        trackerStore.delete(at: indexPath)
    }

    func dateSelected(date: DateWoTime) {
        selectedDate = date
        refreshData()
    }

    func toggleComplete(at indexPath: IndexPath) {
        trackerStore.toggleComplete(at: indexPath, on: selectedDate)
    }

    func togglePin(at indexPath: IndexPath) {
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
        addTrackerNavControllet?.dismiss(animated: true)
        addTrackerNavControllet = nil
    }
}

extension TrackerListViewController: StoreDelegate {
    func store(didUpdate update: StoreUpdate) {
        contentView.update(update)
    }
}
