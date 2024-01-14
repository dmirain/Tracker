import Foundation

final class CreateTrackerController: BaseUIViewController {
    private let contentView: CreateTrackerView

    var trackerType: TrackerType = .event
    
    init(contentView: CreateTrackerView) {
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .popover
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
       self.view = contentView
    }
}
