import Foundation

final class AddTrackerController: BaseUIViewController {
    private let contentView: AddTrackerView
    private let createTrackerController: CreateTrackerController
    
    init(
        contentView: AddTrackerView,
        createTrackerController: CreateTrackerController
    ) {
        self.contentView = contentView
        self.createTrackerController = createTrackerController
        
        super.init(nibName: nil, bundle: nil)
        
        contentView.controller = self
        modalPresentationStyle = .popover
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
       self.view = contentView
    }
}

extension AddTrackerController: AddTrackerViewDelegat {
    func createClicked(type: TrackerType) {
        createTrackerController.trackerType = type
        present(createTrackerController, animated: true)
    }
}
