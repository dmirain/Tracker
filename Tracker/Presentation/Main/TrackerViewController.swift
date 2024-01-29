import UIKit

final class TrackerViewController: UIViewController {
    private let contentView: TrackerListView
    private var addTrackerNavControllet: UINavigationController?
    private let addTrackerController: AddTrackerController
    private let trackerRepository: TrackerRepository
    private let trackerRecordRepository: TrackerRecordRepository

    private var trackerListViewModel = TrackerListViewModel(
        selectedDate: DateWoTime(),
        searchQuery: nil
    )

    init(
        contentView: TrackerListView,
        addTrackerController: AddTrackerController,
        trackerRepository: TrackerRepository,
        trackerRecordRepository: TrackerRecordRepository
    ) {
        self.contentView = contentView
        self.addTrackerController = addTrackerController
        self.trackerRepository = trackerRepository
        self.trackerRecordRepository = trackerRecordRepository

        super.init(nibName: nil, bundle: nil)

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
        let trackers = trackerRepository.filter(
            byDate: trackerListViewModel.selectedDate,
            byName: trackerListViewModel.searchQuery
        )
        let completedTrackers = trackerRecordRepository.filter(trackers: trackers)
        trackerListViewModel.updateTrackersData(trackers: trackers, completedTrackers: completedTrackers)
        contentView.reload()
    }
}

extension TrackerViewController: TrackerListViewDelegat {
    var viewModel: TrackerListViewModel {
        trackerListViewModel
    }

    func addTrackerClicked() {
        addTrackerController.initData(parentDelegat: self, selectedDate: trackerListViewModel.selectedDate)

        let addTrackerNavControllet = UINavigationController(rootViewController: addTrackerController)
        self.addTrackerNavControllet = addTrackerNavControllet

        present(addTrackerNavControllet, animated: true)
    }

    func dateSelected(date: DateWoTime) {
        trackerListViewModel.selectedDate = date
        refreshData()
    }

    func toggleComplete(_ tracker: Tracker) {
        trackerRecordRepository.toggleComplete(tracker, on: trackerListViewModel.selectedDate)
        refreshData()
    }
}

extension TrackerViewController: AddParentDelegateProtocol {
    func compleateAdd(action: EditAction) {
        switch action {
        case .save:
            refreshData()
        case .cancel:
            break
        }
        addTrackerNavControllet?.dismiss(animated: true)
    }
}
