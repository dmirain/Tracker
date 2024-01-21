import UIKit

final class TrackerViewController: BaseUIViewController {
    private let contentView: TrackerView
    private let addTrackerController: AddTrackerController

    init(
        contentView: TrackerView,
        addTrackerController: AddTrackerController
    ) {
        self.contentView = contentView
        
        self.addTrackerController = addTrackerController
        
        super.init(nibName: nil, bundle: nil)
        
        self.contentView.controller = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
       self.view = contentView
    }
}

extension TrackerViewController: TrackerViewDelegat {
    func addTrackerClicked() {
        present(addTrackerController, animated: true)
    }
}
