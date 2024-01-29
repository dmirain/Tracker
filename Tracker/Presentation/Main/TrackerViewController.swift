import UIKit

final class TrackerViewController: UIViewController {
    private let contentView: TrackerListView
    private let addTrackerController: AddTrackerController
    private let trackerRepository: TrackerRepository
        
    private var trackerListViewModel: TrackerListViewModel = TrackerListViewModel(
        trackers: [],
        selectedDate: Date(),
        searchQuery: nil
    )
    
    init(
        contentView: TrackerListView,
        addTrackerController: AddTrackerController,
        trackerRepository: TrackerRepository
    ) {
        self.contentView = contentView
        self.addTrackerController = addTrackerController
        self.trackerRepository = trackerRepository
        
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
        trackerListViewModel.updateTrackers(trackers: trackers)
                
        contentView.reload()
    }
}

extension TrackerViewController: TrackerListViewDelegat {
    var viewModel: TrackerListViewModel {
        trackerListViewModel
    }
    
    func addTrackerClicked() {
        addTrackerController.delegate = self
        present(addTrackerController, animated: true)
    }
    
    func dateSelected(date: Date) {
        trackerListViewModel.selectedDate = date
        refreshData()
    }
}

extension TrackerViewController: AddTrackerControllerDelegate {
    func compleateAdd(action: EditAction, controller: UIViewController) {
        switch action {
        case .save: refreshData()
        case .cancel: break
        }
        controller.dismiss(animated: false)
    }
}
