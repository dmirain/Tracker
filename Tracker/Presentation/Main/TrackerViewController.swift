import UIKit
import Swinject

final class TrackerViewController: UIViewController {
    private let diResolver: Resolver
    private let contentView: TrackerListView
    private var addTrackerController: AddTrackerController?
    private var addTrackerNavControllet: UINavigationController?
    private let trackerRepository: TrackerRepository
    private let trackerRecordRepository: TrackerRecordRepository

    private var trackerListViewModel = TrackerListViewModel(
        selectedDate: DateWoTime(),
        searchQuery: nil
    )

    init(
        diResolver: Resolver,
        contentView: TrackerListView,
        trackerRepository: TrackerRepository,
        trackerRecordRepository: TrackerRecordRepository
    ) {
        self.diResolver = diResolver
        self.contentView = contentView
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

extension TrackerViewController: TrackerListViewDelegate {
    var viewModel: TrackerListViewModel {
        trackerListViewModel
    }

    func addTrackerClicked() {
        guard let addTrackerController = diResolver.resolve(AddTrackerController.self) else { return }
        self.addTrackerController = addTrackerController
        addTrackerController.initData(parentDelegate: self, selectedDate: trackerListViewModel.selectedDate)

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
        self.addTrackerController = nil
    }
}
