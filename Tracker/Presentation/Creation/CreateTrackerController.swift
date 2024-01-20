import Foundation

final class CreateTrackerController: BaseUIViewController {
    private let contentView: CreateTrackerView
    private let selectScheduleController: SelectScheduleController
    
    var trackerType: TrackerType = .event
    
    init(
        contentView: CreateTrackerView,
        selectScheduleController: SelectScheduleController
    ) {
        self.contentView = contentView
        self.selectScheduleController = selectScheduleController
        
        super.init(nibName: nil, bundle: nil)

        self.contentView.controller = self
        
        modalPresentationStyle = .popover
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
       self.view = contentView
    }
}


extension CreateTrackerController: CreateTrackerViewDelegat {
    func selectSchedule() {
        present(selectScheduleController, animated: true)
    }
}
