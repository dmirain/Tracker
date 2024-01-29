import UIKit

final class TrackerViewController: UIViewController {
    private let contentView: TrackerListView
    private let addTrackerNavControllet: AddTrackerNavControllet
    private let trackerRepository: TrackerRepository
        
    private var trackerListViewModel: TrackerListViewModel = TrackerListViewModel(
        trackers: [],
        selectedDate: Date(),
        searchQuery: nil
    )
    
    init(
        contentView: TrackerListView,
        addTrackerNavControllet: AddTrackerNavControllet,
        trackerRepository: TrackerRepository
    ) {
        self.contentView = contentView
        self.addTrackerNavControllet = addTrackerNavControllet
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
        addTrackerNavControllet.parentDelegate = self
        present(addTrackerNavControllet, animated: true)
    }
    
    func dateSelected(date: Date) {
        trackerListViewModel.selectedDate = date
        refreshData()
    }
}

extension TrackerViewController: AddTrackerNavControlletDelegate {
    func compleateAdd(action: EditAction) {
        switch action {
        case .save: refreshData()
        case .cancel: break
        }
        addTrackerNavControllet.dismiss(animated: true)
    }
}
