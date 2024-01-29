import Foundation
import UIKit

protocol SelectScheduleControllerDelegate: AnyObject {
    func set(schedule: WeekDaySet)
}

final class SelectScheduleController: UIViewController {
    private let contentView: SelectScheduleView
    
    weak var delegate: SelectScheduleControllerDelegate?
    
    var schedule: WeekDaySet = []

    init(contentView: SelectScheduleView) {
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)

        self.contentView.controller = self
        
        navigationItem.title = "Расписание"
        navigationItem.hidesBackButton = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
       self.view = contentView
    }
    
    func initData(schedule: WeekDaySet) {
        contentView.initData()
    }
}

extension SelectScheduleController: SelectScheduleViewDelegat {
    func completeSelect() {
        delegate?.set(schedule: schedule)
    }
}
