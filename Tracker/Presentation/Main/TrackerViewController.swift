import UIKit

final class TrackerViewController: BaseUIViewController {
    private let contentView: TrackerView
    private let addTrackerController: AddTrackerController
    private let trackerRepository: TrackerRepository
    
    private var currentDay: Date? = Date()
    private var searchQ: String? = nil
    
    private var trackers: [Tracker] = []
    
    init(
        contentView: TrackerView,
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
        
        trackers = trackerRepository.filter(byDate: currentDay, byName: searchQ)
        contentView.initData(trackers: trackers)
    }
}

extension TrackerViewController: TrackerViewDelegat {
    func addTrackerClicked() {
        present(addTrackerController, animated: true)
    }
}
