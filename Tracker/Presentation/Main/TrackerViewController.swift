import UIKit

protocol TrackerViewControllerDepsFactory: AnyObject {
    func getAddController(
        parentDelegate: AddParentDelegateProtocol,
        selectedDate: DateWoTime
    ) -> AddTrackerController?
}

final class TrackerViewController: UIViewController {
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

extension TrackerViewController: TrackerListViewDelegate {
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
        trackerStore.sectionName(section)
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

    func dateSelected(date: DateWoTime) {
        selectedDate = date
        refreshData()
    }

    func toggleComplete(at indexPath: IndexPath) {
        trackerStore.toggleComplete(at: indexPath, on: selectedDate)
    }
}

extension TrackerViewController: AddParentDelegateProtocol {
    func compleateAdd(action: EditAction, newTracker: Tracker?) {
        switch action {
        case .save:
            if let newTracker {
                trackerStore.add(newTracker)
            }
        case .cancel:
            break
        }
        addTrackerNavControllet?.dismiss(animated: true)
        addTrackerNavControllet = nil
    }
}

extension TrackerViewController: StoreDelegate {
    func store(didUpdate update: StoreUpdate) {
        contentView.update(update)
    }
}
