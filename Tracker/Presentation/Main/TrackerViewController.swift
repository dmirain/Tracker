import UIKit

final class TrackerViewController: UIViewController {
    private let contentView: TrackerListView
    private let addTrackerController: AddTrackerController
    private let trackerRepository: TrackerRepository
    
    private var currentDay: Date? = Date()
    private var searchQ: String? = nil
    
    private var _trackerListViewModel: TrackerListViewModel = TrackerListViewModel(trackers: [])
    
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
        
        let trackers = trackerRepository.filter(byDate: currentDay, byName: searchQ)
        _trackerListViewModel = TrackerListViewModel(trackers: trackers)
        
        contentView.reload()
    }
}

extension TrackerViewController: TrackerListViewDelegat {
    var trackerListViewModel: TrackerListViewModel {
        _trackerListViewModel
    }
    
    func addTrackerClicked() {
        present(addTrackerController, animated: true)
    }
}
