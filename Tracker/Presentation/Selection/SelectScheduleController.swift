import Foundation
import UIKit

protocol SelectScheduleControllerDelegate: AnyObject {
    func set(schedule: WeekDaySet, controller: UIViewController)
}

final class SelectScheduleController: UIViewController {
    private let contentView: SelectScheduleView
    
    weak var delegate: SelectScheduleControllerDelegate?

    init(contentView: SelectScheduleView) {
        self.contentView = contentView
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
    
    func initData(schedule: WeekDaySet) {
        contentView.initData(schedule: schedule)
    }
}

extension SelectScheduleController: SelectScheduleViewDelegat {
    func set(schedule: WeekDaySet) {
        delegate?.set(schedule: schedule, controller: self)
    }
}
